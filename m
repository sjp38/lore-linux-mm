Subject: Re: [kvm-devel] [PATCH] export notifier #1
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <47974C78.7050509@qumranet.com>
References: <478E4356.7030303@qumranet.com>
	 <20080117162302.GI7170@v2.random> <478F9C9C.7070500@qumranet.com>
	 <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random>
	 <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random>
	 <20080122200858.GB15848@v2.random>
	 <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>
	 <4797384B.7080200@redhat.com> <20080123131939.GJ26420@sgi.com>
	 <47974C78.7050509@qumranet.com>
Content-Type: text/plain
Date: Thu, 24 Jan 2008 15:03:07 +1100
Message-Id: <1201147387.6815.29.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Gerd Hoffmann <kraxel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, steiner@sgi.com, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-23 at 16:17 +0200, Avi Kivity wrote:
> Robin Holt wrote:
> > On Wed, Jan 23, 2008 at 01:51:23PM +0100, Gerd Hoffmann wrote:
> >   
> >> Jumping in here, looks like this could develop into a direction useful
> >> for Xen.
> >>
> >> Background:  Xen has a mechanism called "grant tables" for page sharing.
> >>  Guest #1 can issue a "grant" for another guest #2, which in turn then
> >> can use that grant to map the page owned by guest #1 into its address
> >> space.  This is used by the virtual network/disk drivers, i.e. typically
> >> Domain-0 (which has access to the real hardware) maps pages of other
> >> guests to fill in disk/network data.
> >>     
> >
> > This is extremely similar to what XPMEM is providing.
> >
> >   
> 
> I think that in Xen's case the page tables are the normal cpu page 
> tables, not an external mmu (like RDMA, kvm, and XPMEM).

However, that will be useful to the DRI folks as modern video chips are
growing MMU with even page fault capabilities.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
