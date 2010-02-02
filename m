Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C18016B0096
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 14:53:04 -0500 (EST)
Date: Tue, 2 Feb 2010 13:52:11 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 32 of 32] khugepaged
In-Reply-To: <20100201225624.GB4135@random.random>
Message-ID: <alpine.DEB.2.00.1002021347520.19529@router.home>
References: <patchbomb.1264969631@v2.random> <51b543fab38b1290f176.1264969663@v2.random> <alpine.DEB.2.00.1002011551560.2384@router.home> <20100201225624.GB4135@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Feb 2010, Andrea Arcangeli wrote:

> KSM also works exactly the same as khugepaged and migration but we
> solved it without migration pte and apparently nobody wants to deal
> with that special migration pte logic. So before worrying about
> khugepaged out of the tree, you should actively go fix ksm that works
> exactly the same and it's in mainline. Until you don't fix ksm I think
> I should be allowed to keep khugepaged simple and lightweight without
> being forced to migration pte.

You are being "forced"? What language... You do not want to reuse the ksm
code or the page migration code?

Please consider consolidating the code for the multiple ways that we do
these complex moves of physical memory without changing the physical one.

The code needs to be understandable and easy to maintain after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
