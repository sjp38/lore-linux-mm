Date: Tue, 19 Jun 2007 16:59:32 +0100
Subject: Re: [PATCH 2/7] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
Message-ID: <20070619155932.GC17109@skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <20070618092901.7790.31240.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0706180956440.4751@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706180956440.4751@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On (18/06/07 10:04), Christoph Lameter didst pronounce:
> On Mon, 18 Jun 2007, Mel Gorman wrote:
> 
> > 
> > CONFIG_MIGRATION currently depends on CONFIG_NUMA. move_pages() is the only
> > user of migration today and as this system call is only meaningful on NUMA,
> > it makes sense. However, memory compaction will operate within a zone and is
> 
> There are more user of migration. move_pages is one of them, then there is
> cpuset process migration, MPOL_BIND page migration and sys_migrate_pages 
> for explicit process migration.

Ok, this was poor phrasing. Each of those features are NUMA related even
though the core migration mechanism is not dependant on NUMA.

> 
> > useful on both NUMA and non-NUMA systems. This patch allows CONFIG_MIGRATION
> > to be used in all memory models. To preserve existing behaviour, move_pages()
> > is only available when CONFIG_NUMA is set.
> 
> What does this have to do with memory models? A bit unclear.
> 

More poor phrasing. It would have been clearer to simply say that the
patch allows CONFIG_MIGRATION to be used without NUMA.

> Otherwise
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
