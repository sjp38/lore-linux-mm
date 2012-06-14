Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 19B296B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:02:33 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3284454dak.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:02:32 -0700 (PDT)
Date: Fri, 15 Jun 2012 00:02:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix page reclaim comment error
Message-ID: <20120614150223.GB2097@barrios>
References: <1339677662-25942-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339677662-25942-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, trivial@kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Thu, Jun 14, 2012 at 08:41:02PM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Since there are five lists in LRU cache, the array nr in get_scan_count
> should be:
> 
> nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
> nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
