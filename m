Date: Thu, 8 Jun 2006 21:01:01 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 06/14] Add per zone counters to zone node and global VM
 statistics
Message-Id: <20060608210101.155e8d4f.akpm@osdl.org>
In-Reply-To: <20060608230310.25121.77780.sendpatchset@schroedinger.engr.sgi.com>
References: <20060608230239.25121.83503.sendpatchset@schroedinger.engr.sgi.com>
	<20060608230310.25121.77780.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Thu, 8 Jun 2006 16:03:10 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> --- linux-2.6.17-rc6-mm1.orig/mm/page_alloc.c	2006-06-08 14:29:46.317675014 -0700
> +++ linux-2.6.17-rc6-mm1/mm/page_alloc.c	2006-06-08 14:57:05.712250246 -0700
> @@ -628,6 +628,8 @@ static int rmqueue_bulk(struct zone *zon
>  	return i;
>  }
>  
> +char *vm_stat_item_descr[NR_STAT_ITEMS] = { "mapped","pagecache" };

static?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
