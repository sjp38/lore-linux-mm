Date: Tue, 25 May 2004 10:54:42 -0700
From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
Message-Id: <20040525105442.2ebdc355.davem@redhat.com>
In-Reply-To: <Pine.LNX.4.58.0405251034040.9951@ppc970.osdl.org>
References: <1085369393.15315.28.camel@gaston>
	<Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
	<1085371988.15281.38.camel@gaston>
	<Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
	<1085373839.14969.42.camel@gaston>
	<Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
	<20040525034326.GT29378@dualathlon.random>
	<Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
	<20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk>
	<Pine.LNX.4.58.0405250726000.9951@ppc970.osdl.org>
	<20040525153501.GA19465@foobazco.org>
	<Pine.LNX.4.58.0405250841280.9951@ppc970.osdl.org>
	<20040525102547.35207879.davem@redhat.com>
	<Pine.LNX.4.58.0405251034040.9951@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: wesolows@foobazco.org, willy@debian.org, andrea@suse.de, benh@kernel.crashing.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, bcrl@kvack.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2004 10:49:21 -0700 (PDT)
Linus Torvalds <torvalds@osdl.org> wrote:

> So what I can tell, the fix is really something like this (this does both 
> x86 and ppc64 just to show how two different approaches would handle it, 
> but I have literally _tested_ neither).
> 
> What do people think?

So on sparc32 sun4m we'd implement ptep_update_dirty_accessed() with
some kind of loop using the swap instruction?  That's in fact what
I've always wanted, someway to easily integrate the usage of such
a loop so that we could handle this problem on such systems.

Keith?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
