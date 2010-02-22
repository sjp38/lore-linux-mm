Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7BDF46B0047
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 05:23:40 -0500 (EST)
Date: Mon, 22 Feb 2010 11:22:23 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 00/36] Transparent Hugepage support #11
Message-ID: <20100222102223.GD11504@random.random>
References: <20100221141009.581909647@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100221141009.581909647@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

Hello everyone,

On Sun, Feb 21, 2010 at 03:10:09PM +0100, aarcange@redhat.com wrote:
> This is a port of the latest version of transparent hugepage to
> git://zen-kernel.org/kernel/mmotm.git
> 
> The relevant changes are the addition of the page_anon_vma patch, the patch to
> adapt the rss accounting to -mm, and a one liner fix in the
> clear_copy_huge_page cleanup patch (that was crashing hugetlbfs).
> 
> 	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc7-mm1+/transparent_hugepage-11/

somebody asked a single patch to test on top of
git://zen-kernel.org/kernel/mmotm.git so here it is:

http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc7-mm1+/transparent_hugepage-11.gz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
