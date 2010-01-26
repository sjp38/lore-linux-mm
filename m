Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AFC986003C1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 10:52:04 -0500 (EST)
Date: Tue, 26 Jan 2010 16:51:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02 of 31] compound_lock
Message-ID: <20100126155118.GL30452@random.random>
References: <patchbomb.1264513915@v2.random>
 <1037f5f6264364a9e4cc.1264513917@v2.random>
 <4B5F0179.6070005@redhat.com>
 <alpine.DEB.2.00.1001260935510.23549@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001260935510.23549@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 09:36:19AM -0600, Christoph Lameter wrote:
> On Tue, 26 Jan 2010, Rik van Riel wrote:
> 
> > Maybe this should be under an #ifdef so it does not take
> > up a bit flag on 32 bit systems where it isn't compiled?
> 
> I have made the same comment on earlier versions.

Maybe I misunderstood your comment but note that I answered to that
comment of yours with "So I can optimize away that PG_compound_lock
with CONFIG_TRANSPARENT_HUGEPAGE=n if you want.". This is exactly what
I did now, and you didn't answer to my reply, so I had no way to be
sure that's the only thing you meant with TRANSP_HUGE, in which case
we would have been in full agreement already.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
