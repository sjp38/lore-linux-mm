Date: Wed, 9 Apr 2008 08:29:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][trivial fix] add "Isolate" migratetype name to
 /proc/pagetypeinfo.
Message-Id: <20080409082946.93c9a9df.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2f11576a0804080952n3041e1edw94978843833f0953@mail.gmail.com>
References: <2f11576a0804080952n3041e1edw94978843833f0953@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Apr 2008 01:52:44 +0900
"KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:

> patch against: 2.6.25-rc8-mm1
> 
> in a5d76b54a3f3a40385d7f76069a2feac9f1bad63 (memory unplug: page
> isolation by KAMEZAWA Hiroyuki), "isolate" migratetype added.
> but unfortunately, it doesn't treat /proc/pagetypeinfo display logic.
> 
> this patch add "Isolate" to pagetype name field.
> 
Thanks,

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> 
> /proc/pagetype
> before:
> ------------------------------------------------------------------------------------------------------------------------
> Free pages count per migrate type at order       0      1      2
> 3      4      5      6      7      8      9     10
> Node    0, zone      DMA, type    Unmovable      1      2      2
> 2      1      2      2      1      1      0      0
> Node    0, zone      DMA, type  Reclaimable      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type      Movable      2      3      3
> 1      3      3      2      0      0      0      0
> Node    0, zone      DMA, type      Reserve      0      0      0
> 0      0      0      0      0      0      0      1
> Node    0, zone      DMA, type       <NULL>      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type    Unmovable      1      9      7
> 4      1      1      1      1      0      0      0
> Node    0, zone   Normal, type  Reclaimable      5      2      0
> 0      1      1      0      0      0      1      0
> Node    0, zone   Normal, type      Movable      0      1      1
> 0      0      0      1      0      0      1     60
> Node    0, zone   Normal, type      Reserve      0      0      0
> 0      0      0      0      0      0      0      1
> Node    0, zone   Normal, type       <NULL>      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone  HighMem, type    Unmovable      0      0      1
> 1      1      0      1      1      2      2      0
> Node    0, zone  HighMem, type  Reclaimable      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone  HighMem, type      Movable    236     62      6
> 2      2      1      1      0      1      1     16
> Node    0, zone  HighMem, type      Reserve      0      0      0
> 0      0      0      0      0      0      0      1
> Node    0, zone  HighMem, type       <NULL>      0      0      0
> 0      0      0      0      0      0      0      0
> 
> Number of blocks type     Unmovable  Reclaimable      Movable
> Reserve       <NULL>
> Node 0, zone      DMA            1            0            2
>  1            0
> Node 0, zone   Normal           10           40          169
>  1            0
> Node 0, zone  HighMem            2            0          283
>  1            0
> 
> after:
> ------------------------------------------------------------------------------------------------------------------------
> Free pages count per migrate type at order       0      1      2
> 3      4      5      6      7      8      9     10
> Node    0, zone      DMA, type    Unmovable      1      2      2
> 2      1      2      2      1      1      0      0
> Node    0, zone      DMA, type  Reclaimable      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone      DMA, type      Movable      2      3      3
> 1      3      3      2      0      0      0      0
> Node    0, zone      DMA, type      Reserve      0      0      0
> 0      0      0      0      0      0      0      1
> Node    0, zone      DMA, type      Isolate      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone   Normal, type    Unmovable      0      2      1
> 1      0      1      0      0      0      0      0
> Node    0, zone   Normal, type  Reclaimable      1      1      1
> 1      1      0      1      1      1      0      0
> Node    0, zone   Normal, type      Movable      0      1      1
> 1      0      1      0      1      0      0    196
> Node    0, zone   Normal, type      Reserve      0      0      0
> 0      0      0      0      0      0      0      1
> Node    0, zone   Normal, type      Isolate      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone  HighMem, type    Unmovable      0      1      0
> 0      0      1      1      1      2      2      0
> Node    0, zone  HighMem, type  Reclaimable      0      0      0
> 0      0      0      0      0      0      0      0
> Node    0, zone  HighMem, type      Movable      1      0      1
> 1      0      0      0      0      1      0    200
> Node    0, zone  HighMem, type      Reserve      0      0      0
> 0      0      0      0      0      0      0      1
> Node    0, zone  HighMem, type      Isolate      0      0      0
> 0      0      0      0      0      0      0      0
> 
> Number of blocks type     Unmovable  Reclaimable      Movable
> Reserve      Isolate
> Node 0, zone      DMA            1            0            2
>  1            0
> Node 0, zone   Normal            8            4          207
>  1            0
> Node 0, zone  HighMem            2            0          283
>  1            0
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  mm/vmstat.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> Index: b/mm/vmstat.c
> ===================================================================
> --- a/mm/vmstat.c       2008-04-05 22:48:24.000000000 +0900
> +++ b/mm/vmstat.c       2008-04-09 01:34:17.000000000 +0900
> @@ -389,6 +389,7 @@ static char * const migratetype_names[MI
>         "Reclaimable",
>         "Movable",
>         "Reserve",
> +       "Isolate",
>  };
> 
>  static void *frag_start(struct seq_file *m, loff_t *pos)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
