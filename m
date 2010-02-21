Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 85EFF6B0078
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:43 -0500 (EST)
Message-Id: <20100221141009.581909647@redhat.com>
Date: Sun, 21 Feb 2010 15:10:09 +0100
From: aarcange@redhat.com
Subject: [patch 00/36] Transparent Hugepage support #11
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

This is a port of the latest version of transparent hugepage to
git://zen-kernel.org/kernel/mmotm.git

The relevant changes are the addition of the page_anon_vma patch, the patch to
adapt the rss accounting to -mm, and a one liner fix in the
clear_copy_huge_page cleanup patch (that was crashing hugetlbfs).

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.33-rc7-mm1+/transparent_hugepage-11/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
