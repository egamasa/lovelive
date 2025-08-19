<script>
  import '../app.css';
</script>

<header class="bg-white shadow-sm border-b">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center py-4 space-y-2 sm:space-y-0">
      <div class="flex items-center space-x-4">
        <h1 class="text-xl font-bold text-gray-900">🪷蓮ノ空ダッシュボード</h1>
      </div>
      <nav class="flex">
        <a href="/" class="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">動画リスト</a>
        <a href="/mirapa-radio" class="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
          みらぱラジオアーカイブ
        </a>
      </nav>
    </div>
  </div>
</header>

<main>
  <slot />
</main>
