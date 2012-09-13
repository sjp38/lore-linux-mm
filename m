Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C98776B015C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 12:08:50 -0400 (EDT)
Subject: Re: [PATCH 0/3 v2] mm: Batch page reclamation under shink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20120911053657.GC14494@bbox>
References: <1347293960.9977.70.camel@schen9-DESK>
	 <20120911053657.GC14494@bbox>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Sep 2012 09:08:50 -0700
Message-ID: <1347552530.9977.101.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, 2012-09-11 at 14:36 +0900, Minchan Kim wrote:

> 
> If you send next versions, please use git-format-patch --thread style.
> Quote from man
> "       If given --thread, git-format-patch will generate In-Reply-To and References
>        headers to make the second and subsequent patch mails appear as replies to the
>        first mail; this also generates a Message-Id header to reference.
> "
> 
> It helps making your all patches in this series thread type in mailbox
> so reviewers can find all patches related to a subject easily.
> 

Thanks for your detailed review of the patch series.  Will incorporate
your suggestions on the next version.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
