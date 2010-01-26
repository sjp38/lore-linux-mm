Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E175E6B00AE
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:47:26 -0500 (EST)
Date: Tue, 26 Jan 2010 20:46:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 30] Transparent Hugepage support #3
Message-ID: <20100126194621.GU30452@random.random>
References: <20100122151947.GA3690@random.random>
 <alpine.DEB.2.00.1001221008360.4176@router.home>
 <20100123175847.GC6494@random.random>
 <alpine.DEB.2.00.1001251529070.5379@router.home>
 <4B5E3CC0.2060006@redhat.com>
 <alpine.DEB.2.00.1001260947580.23549@router.home>
 <20100126161625.GO30452@random.random>
 <20100126164230.GC16468@csn.ul.ie>
 <20100126165254.GR30452@random.random>
 <20100126172613.GD16468@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126172613.GD16468@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 05:26:13PM +0000, Mel Gorman wrote:
> You're not, I beat you to it a long time ago. In fact, I just watched a dumb
> hit smack into a treadmill (feeling badminded) with the browser using huge
> pages in the background just to confirm I wasn't imagining it.  Launched with
> 
> hugectl --shm --heap epiphany-browser
> 
> HugePages_Total:       5
> HugePages_Free:        1
> HugePages_Rsvd:        1
> HugePages_Surp:        5
> Hugepagesize:       4096 kB
> (Surp implies the huge pages were allocated on demand, not statically)

eheh ;)

> Yes, this is not transparent and it's unlikely that a normal user would go
> to the hassle although conceivably a distro could set a launcher to
> automtaically try huge pages where available.

It'll never happen, I think hugetlbfs can't even be mounted by default
on all distro... or it's not writable, otherwise it's a mlock
DoS...

> I'm just saying that hugetlbfs and the existing utilities are not so bad
> as to be slammed. Just because it's possible to do something like this does
> not detract from transparent support in any way.

Agreed, power users can already take advantage from hugepages, I don't
object that, problem is most people can't and we want to take
advantage of them not just in firefox but whenever possible. Another
app using hugepages is knotify4 for example.

> In virtualisation in particular, the lack of swapping makes hugetlbfs a
> no-go in it's current form. No doubt about it and the transparent
> support will certainly shine with respect to KVM.

Exactly.

> On the flip-side, architecture limitations likely make transparent
> support a no-go on IA-64 and very likely PPC64 so it doesn't solve
> everything either.

Exactly! This is how we discovered that hugetlbfs will stay around
maybe forever, regardless how transparent hugepage will expand over
the tmpfs/pagecache layer.

> The existing stuff will continue to exist alongside transparent support
> because they are ideal in different situations.

Agreed.

> FWIW, I'm still reading through the patches and have not spotted anything
> new that is problematic but I'm only half-way through. By and large, I'm
> pro-the-patches but am somewhat compelled to defend hugetlbfs :)

NOTE: I very much defend hugetlbfs too! But not for using it with
firefox on desktop nor on virtualization cloud. For DBMS hugetlbfs may
remain superior solution than transparent hugepage because of the
finegrined reservation capabilities. We're in full agreement ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
