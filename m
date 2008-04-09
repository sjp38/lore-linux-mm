Date: Wed, 9 Apr 2008 11:53:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH][trivial fix] add "Isolate" migratetype name to /proc/pagetypeinfo.
Message-ID: <20080409105328.GB5872@csn.ul.ie>
References: <2f11576a0804080952n3041e1edw94978843833f0953@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0804080952n3041e1edw94978843833f0953@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (09/04/08 01:52), KOSAKI Motohiro didst pronounce:
> patch against: 2.6.25-rc8-mm1
> 


Errr, I acked based on what I saw and immediately afterwards found that
this does not apply cleanly to 2.6.25-rc8-mm1 due to whitespace damage.
Here is a whitespace-undamaged version

======

patch against: 2.6.25-rc8-mm1

in a5d76b54a3f3a40385d7f76069a2feac9f1bad63 (memory unplug: page
isolation by KAMEZAWA Hiroyuki), "isolate" migratetype added.
but unfortunately, it doesn't treat /proc/pagetypeinfo display logic.

this patch add "Isolate" to pagetype name field.


/proc/pagetype
before:
------------------------------------------------------------------------------------------------------------------------
Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      2      2      2      1      2      2      1      1      0      0
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Movable      2      3      3      1      3      3      2      0      0      0      0
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone      DMA, type       <NULL>      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable      1      9      7      4      1      1      1      1      0      0      0
Node    0, zone   Normal, type  Reclaimable      5      2      0      0      1      1      0      0      0      1      0
Node    0, zone   Normal, type      Movable      0      1      1      0      0      0      1      0      0      1     60
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone   Normal, type       <NULL>      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type    Unmovable      0      0      1      1      1      0      1      1      2      2      0
Node    0, zone  HighMem, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type      Movable    236     62      6      2      2      1      1      0      1      1     16
Node    0, zone  HighMem, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone  HighMem, type       <NULL>      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve       <NULL>
Node 0, zone      DMA            1            0            2       1            0
Node 0, zone   Normal           10           40          169       1            0
Node 0, zone  HighMem            2            0          283       1            0

after:
------------------------------------------------------------------------------------------------------------------------
Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone      DMA, type    Unmovable      1      2      2      2      1      2      2      1      1      0      0
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone      DMA, type      Movable      2      3      3      1      3      3      2      0      0      0      0
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type    Unmovable      0      2      1      1      0      1      0      0      0      0      0
Node    0, zone   Normal, type  Reclaimable      1      1      1      1      1      0      1      1      1      0      0
Node    0, zone   Normal, type      Movable      0      1      1      1      0      1      0      1      0      0    196
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type    Unmovable      0      1      0      0      0      1      1      1      2      2      0
Node    0, zone  HighMem, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone  HighMem, type      Movable      1      0      1      1      0      0      0      0      1      0    200
Node    0, zone  HighMem, type      Reserve      0      0      0      0      0      0      0      0      0      0      1
Node    0, zone  HighMem, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate
Node 0, zone      DMA            1            0            2       1            0
Node 0, zone   Normal            8            4          207       1            0
Node 0, zone  HighMem            2            0          283       1            0


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmstat.c |    1 +
 1 file changed, 1 insertion(+)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-rc8-mm1-clean/mm/vmstat.c linux-2.6.25-rc8-mm1-isolate/mm/vmstat.c
--- linux-2.6.25-rc8-mm1-clean/mm/vmstat.c	2008-04-08 08:11:26.000000000 +0100
+++ linux-2.6.25-rc8-mm1-isolate/mm/vmstat.c	2008-04-09 11:35:18.000000000 +0100
@@ -389,6 +389,7 @@ static char * const migratetype_names[MI
 	"Reclaimable",
 	"Movable",
 	"Reserve",
+	"Isolate",
 };
 
 static void *frag_start(struct seq_file *m, loff_t *pos)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
