Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id CB2386B00A2
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 01:34:59 -0400 (EDT)
Date: Tue, 11 Sep 2012 14:36:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3 v2] mm: Batch page reclamation under shink_page_list
Message-ID: <20120911053657.GC14494@bbox>
References: <1347293960.9977.70.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347293960.9977.70.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

Hi Tim,

On Mon, Sep 10, 2012 at 09:19:20AM -0700, Tim Chen wrote:
> This is the second version of the patch series. Thanks to Matthew Wilcox 
> for many valuable suggestions on improving the patches.
> 
> To do page reclamation in shrink_page_list function, there are two
> locks taken on a page by page basis.  One is the tree lock protecting
> the radix tree of the page mapping and the other is the
> mapping->i_mmap_mutex protecting the mapped
> pages.  I try to batch the operations on pages sharing the same lock
> to reduce lock contentions.  The first patch batch the operations protected by
> tree lock while the second and third patch batch the operations protected by 
> the i_mmap_mutex.
> 
> I managed to get 14% throughput improvement when with a workload putting
> heavy pressure of page cache by reading many large mmaped files
> simultaneously on a 8 socket Westmere server.
> 
> Tim
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

If you send next versions, please use git-format-patch --thread style.
Quote from man
"       If given --thread, git-format-patch will generate In-Reply-To and References
       headers to make the second and subsequent patch mails appear as replies to the
       first mail; this also generates a Message-Id header to reference.
"

It helps making your all patches in this series thread type in mailbox
so reviewers can find all patches related to a subject easily.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
