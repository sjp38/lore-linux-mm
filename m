Date: Mon, 18 Jun 2007 10:04:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/7] Allow CONFIG_MIGRATION to be set without CONFIG_NUMA
In-Reply-To: <20070618092901.7790.31240.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0706180956440.4751@schroedinger.engr.sgi.com>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
 <20070618092901.7790.31240.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007, Mel Gorman wrote:

> 
> CONFIG_MIGRATION currently depends on CONFIG_NUMA. move_pages() is the only
> user of migration today and as this system call is only meaningful on NUMA,
> it makes sense. However, memory compaction will operate within a zone and is

There are more user of migration. move_pages is one of them, then there is
cpuset process migration, MPOL_BIND page migration and sys_migrate_pages 
for explicit process migration.

> useful on both NUMA and non-NUMA systems. This patch allows CONFIG_MIGRATION
> to be used in all memory models. To preserve existing behaviour, move_pages()
> is only available when CONFIG_NUMA is set.

What does this have to do with memory models? A bit unclear.

Otherwise

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
