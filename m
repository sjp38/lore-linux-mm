Date: Thu, 13 Dec 2007 09:23:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/6] Use two zonelists per node instead of multiple
 zonelists v11r2
Message-Id: <20071213092338.8b10944c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1197495172.5029.62.camel@localhost>
References: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
	<1197495172.5029.62.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Dec 2007 16:32:51 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Just this afternoon, I hit a null pointer deref in
> __mem_cgroup_remove_list() [called from mem_cgroup_uncharge() if I can
> trust the stack trace] attempting to unmap a page for migration.  I'm
> just starting to investigate this.
> 
> I'll replace the series I have [~V10] with V11r2 and continue testing in
> anticipation of the day that we can get this into -mm.
> 
Hi, Lee-san.

Could you know what is the caller of page migration ?
system call ? hot removal ? or some new thing ?

Note: 2.6.24-rc4-mm1's cgroup/migration logic.

In 2.6.24-rc4-mm1, in page migration, mem_cgroup_prepare_migration() increments
page_cgroup's refcnt before calling try_to_unmap(). This extra refcnt guarantees 
the page_cgroup's refcnt will not drop to 0 in sequence of
unmap_and_move() -> try_to_unmap() -> page_remove_rmap() -> mem_cgroup_unchage(). 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
