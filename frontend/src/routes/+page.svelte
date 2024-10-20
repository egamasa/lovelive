<script>
  import { browser } from '$app/environment';
  import { onMount } from 'svelte';

  const daysOfWeek = ['日', '月', '火', '水', '木', '金', '土'];

  function formatDate(date) {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');

    return `${year}/${month}/${day}（${daysOfWeek[d.getDay()]}）${hours}:${minutes}`;
  }

  function isNew(date) {
    const d = new Date(date);
    const now = new Date();

    const diffTime = Math.abs(now - d);
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    return diffDays <= 7;
  }

  const openExtUrl = (event, url) => {
    event.preventDefault();
    window.open(url, '_blank');
  };

  const videoCategories = [
    {key: 'all', label: 'YouTube 新着'},
    {key: 'mirapaRadio', label: 'みらくら視聴覚室ラジオ'},
    {key: 'seeHasu', label: 'せーので！はすのそら！'},
    {key: 'withMeets', label: 'With×MEETS'},
    {key: 'fesLive', label: 'Fes×LIVE'},
    {key: 'linkNama', label: '#リンクラ生放送'},
    {key: 'story', label: '活動記録'},
    {key: 'lyricVideo', label: 'リリックビデオ'},
  ];
  const noteCategories = [
    {key: 'all', label: 'note'},
  ];

  let videos = {
    all: [],
    withMeets: [],
    fesLive: [],
    mirapaRadio: [],
    seeHasu: [],
    linkNama: [],
    story: [],
    lyricVideo: [],
  };
  let notes = {
    all: [],
  }
  let lastUpdate = null;

  const getContents = async () => {
    try {
      const response = await fetch('https://data.orangeliner.net/hasu/contents.json');
      const data = await response.json();
      videos = data.videos;
      notes = data.notes;
      lastUpdate = data.lastUpdate;
    } catch (error) {
      console.error('データ取得エラー', error);
    }
  };

  onMount(() => {
    getContents();
  });
</script>

<svelte:head>
  <title>蓮ノ空ダッシュボード - orangeliner.net</title>
</svelte:head>

<div class="mx-auto p-3 lg:p-6">
  <h1 class="text-3xl font-bold">🪷蓮ノ空ダッシュボード</h1>
  <h2>Powered by <a href="https://orangeliner.net" target="_blank" class="underline">orangeliner.net</a></h2>

  <div class="pt-3">
    <p>Link！Like！ラブライブ！／蓮ノ空女学院スクールアイドルクラブ の新着コンテンツを一覧で確認できます。（各カテゴリ最大5件）</p>
    <p>公開1週間以内のコンテンツには <span class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">New!</span> が表示されます。</p>
    <p>YouTube動画にはプレミア公開前（指定日時より視聴可能）のものも含まれており、サムネイルが表示されない場合があります。</p>
  </div>

  <div class="pt-3">
    <p class="text-sm text-gray-500">Twitter Publish、YouTube Data API、note RSS よりデータを取得しています。</p>
    {#if lastUpdate}<p class="text-sm text-gray-500">データ最終更新日時：{formatDate(lastUpdate)}</p>{/if}
  </div>

  <div class="grid grid-cols-1 md:grid-cols-3 2xl:grid-cols-4 gap-3 pt-3">
    <div>
      {#if browser}
        <a class="twitter-timeline" data-height="570" data-theme="light" href="https://twitter.com/hasunosora_SIC?ref_src=twsrc%5Etfw">Tweets by hasunosora_SIC</a> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
      {/if}
    </div>

    {#each videoCategories as category}
      <div class="border rounded-lg p-3 shadow-lg">
        <h3 class="text-lg font-bold">{category.label}</h3>

        <ul class="divide-y divide-gray-200">
          {#each videos[category.key] as video}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
            <li class="flex py-2 cursor-pointer hover:bg-red-50" on:click={(event) => openExtUrl(event, video.link)}>
              <div>
                <img src={video.thumbnail} alt={video.title} width="110" class="h-15 w-30 object-cover" />
              </div>
              <div class="ml-2 flex-1">
                <a href={video.link} target="_blank">
                  <p class="text-sm line-clamp-3">
                    {#if isNew(video.date)}<span class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">New!</span>{/if}
                    {video.title}
                  </p>
                </a>
                <div class="mt-1 text-sm text-gray-500">
                  <time>{formatDate(video.date)}</time>
                </div>
              </div>
            </li>
          {/each}
        </ul>
      </div>
    {/each}

    {#each noteCategories as category}
      <div class="border rounded-lg p-3 shadow-lg">
        <h3 class="text-lg font-bold">{category.label}</h3>

        <ul class="divide-y divide-gray-200 py-2">
          {#each notes[category.key] as note}
            <!-- svelte-ignore a11y-click-events-have-key-events -->
            <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
            <li class="flex py-2 cursor-pointer hover:bg-red-50" on:click={(event) => openExtUrl(event, note.link)}>
              <div>
                <img src={note.thumbnail} alt={note.title} width="110" class="h-15 w-30 object-cover" />
              </div>
              <div class="ml-2 flex-1">
                <a href={note.link} target="_blank">
                  <p class="text-sm line-clamp-3">
                    {#if isNew(note.date)}<span class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10">New!</span>{/if}
                    {note.title}
                  </p>
                </a>
                <div class="mt-1 text-sm text-gray-500">
                  <time>{formatDate(note.date)}</time>
                </div>
              </div>
            </li>
          {/each}
        </ul>
      </div>
    {/each}
  </div>
</div>
