Date: Tue, 25 May 2004 21:28:10 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
In-Reply-To: <1085544720.5580.9.camel@gaston>
Message-ID: <Pine.LNX.4.58.0405252125590.15534@ppc970.osdl.org>
References: <1085369393.15315.28.camel@gaston>  <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
  <1085371988.15281.38.camel@gaston>  <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
  <1085373839.14969.42.camel@gaston>  <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
  <20040525034326.GT29378@dualathlon.random>  <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
  <20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk>
 <Pine.LNX.4.58.0405250726000.9951@ppc970.osdl.org>  <20040525153501.GA19465@foobazco.org>
  <Pine.LNX.4.58.0405250841280.9951@ppc970.osdl.org>  <20040525102547.35207879.davem@redhat.com>
  <Pine.LNX.4.58.0405251034040.9951@ppc970.osdl.org>  <20040525105442.2ebdc355.davem@redhat.com>
  <Pine.LNX.4.58.0405251056520.9951@ppc970.osdl.org>  <1085521251.24948.127.camel@gaston>
  <Pine.LNX.4.58.0405251452590.9951@ppc970.osdl.org>
 <Pine.LNX.4.58.0405251455320.9951@ppc970.osdl.org>  <1085522860.15315.133.camel@gaston>
  <Pine.LNX.4.58.0405251514200.9951@ppc970.osdl.org>  <1085530867.14969.143.camel@gaston>
  <Pine.LNX.4.58.0405251749500.9951@ppc970.osdl.org>  <1085541906.14969.412.camel@gaston>
  <Pine.LNX.4.58.0405252031270.15534@ppc970.osdl.org> <1085544720.5580.9.camel@gaston>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "David S. Miller" <davem@redhat.com>, wesolows@foobazco.org, willy@debian.org, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, mingo@elte.hu, bcrl@kvack.org, linux-mm@kvack.org, Linux Arch list <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Wed, 26 May 2004, Benjamin Herrenschmidt wrote:
> 
> The first one could still be called "ptep_establish"

Yes.

And the other places should be called "ptep_set_dirty_access()" (and you 
might verify that those bits are the only ones that change, if you want to 
make sure).

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
