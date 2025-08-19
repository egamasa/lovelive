<script lang="ts">
  import list01 from '$lib/mirapa_radio_01.json';
  import list02 from '$lib/mirapa_radio_02.json';
  import list03 from '$lib/mirapa_radio_03.json';
  import list04 from '$lib/mirapa_radio_04.json';
  import list05 from '$lib/mirapa_radio_05.json';
  import list06 from '$lib/mirapa_radio_06.json';

  const radioFiles = {
    list01: {
      data: list01,
      caption: '待機室',
      title: 'かんかん＆こなちのみらくら待機室ラジオ',
      note: '103期：2023年6月～2023年9月'
    },
    list02: {
      data: list02,
      caption: '補習室',
      title: 'かんかん＆こなちのみらくら補習室ラジオ',
      note: '103期：2023年9月～2024年4月'
    },
    list03: {
      data: list03,
      caption: '準備室',
      title: 'みらくら準備室ラジオ',
      note: '104期：2024年4月～2024年9月'
    },
    list04: {
      data: list04,
      caption: '視聴覚室',
      title: 'かんかん＆りんりん＆こなこなのみらくら視聴覚室ラジオ',
      note: '104期：2024年10月～2024年12月'
    },
    list05: {
      data: list05,
      caption: '進路相談室',
      title: 'かんかん＆りんりん＆こなこなのみらくら進路相談室ラジオ',
      note: '104期：2025年1月～2025年3月'
    },
    list06: {
      data: list06,
      caption: 'みらぱの部屋',
      title: 'かんかん＆りんりんのきまっし!!みらぱ！の部屋ラジオ',
      note: '105期：2025年4月～'
    }
  };

  let selectedList = 'list06';

  $: currentData = radioFiles[selectedList].data;

  const daysOfWeek = ['日', '月', '火', '水', '木', '金', '土'];

  function formatDate(date: string | Date) {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');

    return `${year}/${month}/${day}（${daysOfWeek[d.getDay()]}）${hours}:${minutes}`;
  }

  const openExtUrl = (event: MouseEvent, url: string) => {
    event.preventDefault();
    window.open(url, '_blank');
  };
</script>

<div class="container mx-auto p-4">
  <h1 class="text-2xl font-bold mb-4">みらくらぱーく！ラジオ アーカイブ</h1>

  <div class="border rounded-lg shadow-lg">
    <div class="border-b border-gray-200">
      <!-- Mobile dropdown -->
      <div class="sm:hidden px-3 pt-3 pb-3">
        <select bind:value={selectedList} class="block w-full rounded-md border-gray-300 py-2 px-3 text-sm">
          {#each Object.entries(radioFiles) as [key, file]}
            <option value={key}>{file.caption}（{file.note}）</option>
          {/each}
        </select>
      </div>
      <!-- Desktop tabs -->
      <nav class="-mb-px hidden sm:flex px-3 pt-3">
        {#each Object.entries(radioFiles) as [key, file]}
          <button
            on:click={() => (selectedList = key)}
            class="{selectedList === key
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700'} flex-1 border-b-2 py-3 px-4 text-sm font-medium"
          >
            {file.caption}
          </button>
        {/each}
      </nav>
    </div>
    <div class="px-3 pt-3">
      <h2 class="font-bold">{radioFiles[selectedList].title}</h2>
      <p>{radioFiles[selectedList].note}</p>
    </div>
    <div class="p-3">
      <ul class="divide-y divide-gray-200">
        {#each currentData as episode}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
          <li
            class="flex py-2 cursor-pointer hover:bg-red-50"
            on:click={(event) => openExtUrl(event, episode.videoUrl)}
          >
            <div>
              <img src={episode.thumbnailUrl} alt={episode.title} width="120" class="h-15 w-30 object-cover" />
            </div>
            <div class="ml-2 flex-1">
              <a href={episode.videoUrl} target="_blank">
                <h3 class="font-bold">{episode.title}</h3>
                <p>
                  <span
                    class="inline-flex items-center rounded-md bg-green-100 px-2 py-1 text-xs font-medium text-green-700 ring-1 ring-inset ring-green-600/10"
                  >
                    出演
                  </span>
                  {episode.casts}
                  {#if episode.guests}
                    <span
                      class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                    >
                      ゲスト
                    </span>
                    {episode.guests}
                  {/if}
                </p>
                {#if episode.note}
                  <p>{@html episode.note}</p>
                {/if}
                <div class="mt-1 text-sm text-gray-500">
                  <time>{formatDate(episode.publishedAt)}</time>
                </div>
              </a>
            </div>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</div>
