Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E12EF6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:56:24 -0400 (EDT)
Date: Tue, 7 Jul 2009 21:56:56 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
Message-ID: <20090707135656.GB9444@localhost>
References: <20090705211739.091D.A69D9226@jp.fujitsu.com> <20090705130200.GA6585@localhost> <20090707102106.0C66.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707102106.0C66.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 09:22:48AM +0800, KOSAKI Motohiro wrote:
> > On Sun, Jul 05, 2009 at 08:21:20PM +0800, KOSAKI Motohiro wrote:
> > > > On Sun, Jul 05, 2009 at 05:26:18PM +0800, KOSAKI Motohiro wrote:

> @@ -2118,9 +2118,9 @@ void show_free_areas(void)
>  	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
>  		" inactive_file:%lu unevictable:%lu\n"
>  		" isolated_anon:%lu isolated_file:%lu\n"
> -		" dirty:%lu writeback:%lu buffer:%lu unstable:%lu\n"
> +		" dirty:%lu writeback:%lu buffer:%lu shmem:%lu\n"

btw, nfs unstable pages are related to writeback pages, so it may be
better to put "unstable" right after "writeback" (as it was)?

Thanks,
Fengguang


>  		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> -		" mapped:%lu pagetables:%lu bounce:%lu\n",
> +		" mapped:%lu pagetables:%lu unstable:%lu bounce:%lu\n",
>  		global_page_state(NR_ACTIVE_ANON),
>  		global_page_state(NR_ACTIVE_FILE),
>  		global_page_state(NR_INACTIVE_ANON),
> @@ -2131,12 +2131,13 @@ void show_free_areas(void)
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
>  		nr_blockdev_pages(),
> -		global_page_state(NR_UNSTABLE_NFS),
> +		global_page_state(NR_SHMEM),
>  		global_page_state(NR_FREE_PAGES),
>  		global_page_state(NR_SLAB_RECLAIMABLE),
>  		global_page_state(NR_SLAB_UNRECLAIMABLE),
>  		global_page_state(NR_FILE_MAPPED),
>  		global_page_state(NR_PAGETABLE),
> +		global_page_state(NR_UNSTABLE_NFS),
>  		global_page_state(NR_BOUNCE));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
