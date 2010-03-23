Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 099F06B0071
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:12:51 -0400 (EDT)
Date: Tue, 23 Mar 2010 12:11:01 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 34] Transparent Hugepage support #14
In-Reply-To: <20100322182028.GA13114@cmpxchg.org>
Message-ID: <alpine.DEB.2.00.1003231208370.10178@router.home>
References: <patchbomb.1268839142@v2.random> <alpine.DEB.2.00.1003171353240.27268@router.home> <20100318234923.GV29874@random.random> <alpine.DEB.2.00.1003190812560.10759@router.home> <20100319144101.GB29874@random.random> <alpine.DEB.2.00.1003221027590.16606@router.home>
 <20100322163523.GA12407@cmpxchg.org> <alpine.DEB.2.00.1003221139300.17230@router.home> <20100322182028.GA13114@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Mar 2010, Johannes Weiner wrote:

> Migration happens on the fly as well, you can just hide it better for
> cases like mremap(), which is unaffected by the actual entries it copies.

No it does not happen on the fly. It happens only when you can account for
all references that current exist for the page to be migrated. Then you
change all the references at once. The mechanism ensures that there is no
one else operating on the page.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
