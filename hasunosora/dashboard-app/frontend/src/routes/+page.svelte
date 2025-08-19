<script lang="ts">
  import { browser } from '$app/environment';
  import { onMount } from 'svelte';

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

  function isNew(date: string | Date) {
    const d = new Date(date);
    const now = new Date();

    const diffTime = Math.abs(now.valueOf() - d.valueOf());
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

    return diffDays <= 7;
  }

  const openExtUrl = (event: MouseEvent, url: string) => {
    event.preventDefault();
    window.open(url, '_blank');
  };

  interface Video {
    title: string;
    link: string;
    date: string | Date;
    thumbnail: string;
    upcoming: boolean;
  }

  interface Videos {
    all: Video[];
    fesLive: Video[];
    mirapaRadio: Video[];
    seeHasu: Video[];
    membership: Video[];
    linkNama: Video[];
    story: Video[];
    lyricVideo: Video[];
  }

  interface VideoCategory {
    key: keyof Videos;
    label: string;
  }

  interface Book {
    title: string;
    author: string;
    link: string;
    date: string | Date;
    thumbnail: string;
  }

  interface Books {
    hinoshita: Book[];
  }

  interface Note {
    title: string;
    link: string;
    date: string | Date;
    thumbnail: string;
  }

  interface Notes {
    all: Note[];
  }

  interface NoteCategory {
    key: keyof Notes;
    label: string;
  }

  let videos: Videos = {
    all: [],
    fesLive: [],
    mirapaRadio: [],
    seeHasu: [],
    membership: [],
    linkNama: [],
    story: [],
    lyricVideo: []
  };

  let books: Books = {
    hinoshita: []
  };

  let notes: Notes = {
    all: []
  };

  let lastUpdate: Date | null = null;

  const videoCategories: VideoCategory[] = [
    { key: 'all', label: 'YouTube 新着' },
    { key: 'mirapaRadio', label: 'きまっし!! みらぱ！の部屋ラジオ' },
    { key: 'seeHasu', label: 'せーので！はすのそら！' },
    { key: 'membership', label: 'メンバーシップ限定動画' },
    { key: 'linkNama', label: '#リンクラ生放送' },
    { key: 'story', label: '活動記録' },
    { key: 'fesLive', label: 'Fes×LIVE' },
    { key: 'lyricVideo', label: 'リリックビデオ' }
  ];

  const noteCategories: NoteCategory[] = [{ key: 'all', label: 'note' }];

  const getContents = async () => {
    try {
      const contentsResponse = await fetch('https://data.orangeliner.net/hasu/contents.json', {
        cache: 'no-cache'
      });
      const contentsData = await contentsResponse.json();
      videos = contentsData.videos;
      notes = contentsData.notes;
      lastUpdate = new Date(contentsData.lastUpdate);

      const booksResponse = await fetch('https://data.orangeliner.net/hasu/books.json', {
        cache: 'no-cache'
      });
      const booksData = await booksResponse.json();
      books = booksData;
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
  <description>Link！Like！ラブライブ！／蓮ノ空女学院スクールアイドルクラブの新着コンテンツを一覧で確認</description>
  <meta property="og:type" content="website" />
  <meta property="og:title" content="蓮ノ空ダッシュボード" />
  <meta
    property="og:description"
    content="Link！Like！ラブライブ！／蓮ノ空女学院スクールアイドルクラブの新着コンテンツを一覧で確認"
  />
  <meta property="og:url" content="https://hasu.orangeliner.net" />
  <meta property="og:image" content="https://hasu.orangeliner.net/ogp.png" />
  <meta property="og:site_name" content="orangeliner.net" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="蓮ノ空ダッシュボード" />
  <meta
    name="twitter:description"
    content="Link！Like！ラブライブ！／蓮ノ空女学院スクールアイドルクラブの新着コンテンツを一覧で確認"
  />
  <meta name="twitter:site" content="@asagiri96mc" />
</svelte:head>

<div class="mx-auto p-3 lg:p-6">
  <div>
    <p>
      Link！Like！ラブライブ！／蓮ノ空女学院スクールアイドルクラブ
      の新着コンテンツを一覧で確認できます。（各カテゴリ最大5件）
    </p>
    <p>
      公開1週間以内のコンテンツには
      <span
        class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
      >
        New!
      </span>
      が表示されます。
    </p>
    <p>
      ライブ配信予定またはプレミア公開前のYouTube動画には
      <span
        class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20"
      >
        配信予定
      </span>
      が表示されます。
    </p>
  </div>

  <div class="pt-3">
    <p class="text-sm text-gray-500">Twitter Publish、YouTube Data API、note RSS よりデータを取得しています。</p>
    {#if lastUpdate}<p class="text-sm text-gray-500">データ最終更新日時：{formatDate(lastUpdate)}</p>{/if}
  </div>

  <div class="grid grid-cols-1 md:grid-cols-3 2xl:grid-cols-4 gap-3 pt-3">
    <div>
      {#if browser}
        <a
          class="twitter-timeline"
          data-height="570"
          data-theme="light"
          href="https://twitter.com/hasunosora_SIC?ref_src=twsrc%5Etfw"
        >
          Tweets by hasunosora_SIC
        </a>
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
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
                    {#if video.upcoming}<span
                        class="inline-flex items-center rounded-md bg-yellow-50 px-2 py-1 text-xs font-medium text-yellow-800 ring-1 ring-inset ring-yellow-600/20"
                        >配信予定</span
                      >
                    {:else if isNew(video.date)}
                      <span
                        class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                      >
                        New!
                      </span>
                    {/if}
                    {video.title}
                  </p>
                </a>
                {#if video.upcoming}
                  <div class="mt-1 text-sm text-red-800 font-medium">
                    <time>{formatDate(video.date)}</time>
                  </div>
                {:else}
                  <div class="mt-1 text-sm text-gray-500">
                    <time>{formatDate(video.date)}</time>
                  </div>
                {/if}
              </div>
            </li>
          {/each}
        </ul>
      </div>
    {/each}

    <div class="border rounded-lg p-3 shadow-lg">
      <h3 class="text-lg font-bold">日野下図書館</h3>
      <p class="text-sm text-gray-500">Amazonアフィリエイトリンクを含みます</p>
      <ul class="divide-y divide-gray-200 py-2">
        {#each books.hinoshita.reverse().slice(0, 4) as book}
          <!-- svelte-ignore a11y-click-events-have-key-events -->
          <!-- svelte-ignore a11y-no-noninteractive-element-interactions -->
          <li class="flex py-2 cursor-pointer hover:bg-red-50" on:click={(event) => openExtUrl(event, book.link)}>
            <div>
              <img src={book.thumbnail} alt={book.title} width="80" class="h-15 w-30 object-cover" />
            </div>
            <div class="ml-2 flex-1">
              <a href={book.link} target="_blank">
                <p class="text-sm line-clamp-3">
                  {#if isNew(book.date)}
                    <span
                      class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                    >
                      New!
                    </span>
                  {/if}
                  {book.title}
                </p>
                <p class="mt-1 text-sm line-clamp-3">{book.author}</p>
              </a>
              <div class="mt-1 text-sm text-gray-500">
                <time>{formatDate(book.date)}</time>
              </div>
            </div>
          </li>
        {/each}
      </ul>
    </div>

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
                    {#if isNew(note.date)}
                      <span
                        class="inline-flex items-center rounded-md bg-red-100 px-2 py-1 text-xs font-medium text-red-700 ring-1 ring-inset ring-red-600/10"
                      >
                        New!
                      </span>
                    {/if}
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
