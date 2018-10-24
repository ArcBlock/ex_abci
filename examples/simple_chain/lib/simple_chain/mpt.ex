defmodule SimpleChain.Mpt do
  @moduledoc """
  Encapsulate the Merkle Patricia Tree implementation to make it more robust for our use cases
  """
  alias MerklePatriciaTree.{DB, Trie}

  @app_hash "app_hash"
  @last_block "last_block"

  @spec open(String.t()) :: Trie.t()
  def open(dbpath) do
    db = DB.LevelDB.init(dbpath)

    root_hash = get_app_hash(%Trie{db: db})
    Trie.new(db, root_hash)
  end

  @spec put(Trie.t(), any, any) :: Trie.t()
  def put(trie, k, v) do
    trie = Trie.update(trie, k, v)
    %Trie{root_hash: root_hash} = trie
    update_app_hash(trie, root_hash)
    trie
  end

  @spec get(Trie.t(), any) :: any
  def get(trie, k) do
    Trie.get(trie, k)
  end

  @spec update_app_hash(Trie.t(), String.t()) :: :ok
  def update_app_hash(%Trie{db: db}, hash) do
    DB.put!(db, @app_hash, hash)
  end

  @spec update_block(Trie.t(), non_neg_integer()) :: :ok
  def update_block(%Trie{db: db, root_hash: root_hash}, height) do
    DB.put!(db, height, root_hash)
    DB.put!(db, @last_block, height)
  end

  @spec get_last_block(Trie.t()) :: non_neg_integer()
  def get_last_block(%Trie{db: db}), do: db_get(db, @last_block, 0)

  @spec get_app_hash(Trie.t()) :: non_neg_integer()
  def get_app_hash(%Trie{db: db}), do: db_get(db, @app_hash, <<>>)

  @spec get_app_hash(Trie.t(), non_neg_integer()) :: non_neg_integer()
  def get_app_hash(%Trie{db: db}, block), do: db_get(db, block, <<>>)

  @spec get_info(Trie.t()) :: map()
  def get_info(trie) do
    block = get_last_block(trie)

    %{
      last_block: block,
      last_block_hash: get_app_hash(trie, block),
      app_hash: get_app_hash(trie)
    }
  end

  # private functions
  def db_get(db, key, default_value) do
    case DB.get(db, key) do
      :not_found -> default_value
      {:ok, v} -> v
    end
  end
end
