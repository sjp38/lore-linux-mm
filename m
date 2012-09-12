Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 3E03D6B00F4
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 15:29:00 -0400 (EDT)
Date: Wed, 12 Sep 2012 12:28:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3 v2] mm: Batch unmapping of file mapped pages in
 shrink_page_list
Message-Id: <20120912122858.8642e382.akpm@linux-foundation.org>
In-Reply-To: <1347293965.9977.71.camel@schen9-DESK>
References: <1347293965.9977.71.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, 10 Sep 2012 09:19:25 -0700
Tim Chen <tim.c.chen@linux.intel.com> wrote:

> @@ -1014,6 +1090,9 @@ keep_lumpy:

I worry that your tree has the label "keep_lumpy" in it!  Are you
developing against recent kernels?

>  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
>  	}
>  
> +	nr_reclaimed += __remove_mapping_batch(&unmap_pages, &ret_pages,
> +					       &free_pages);
> +
>  	/*
>  	 * Tag a zone as congested if all the dirty pages encountered were
>  	 * backed by a congested BDI. In this case, reclaimers should just
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
