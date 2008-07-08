Date: Tue, 8 Jul 2008 14:00:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/6] mm: Allow architectures to define additional protection
 bits
In-Reply-To: <1215497929.8970.207.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0807081358270.25635@blonde.site>
References: <20080618223254.966080905@linux.vnet.ibm.com>
 <20080618223328.856102092@linux.vnet.ibm.com>  <20080701015301.3dc8749b.akpm@linux-foundation.org>
  <1214920499.18690.10.camel@norville.austin.ibm.com>  <1215409956.8970.82.camel@pasglop>
  <Pine.LNX.4.64.0807072143200.27181@blonde.site>  <1215469468.8970.143.camel@pasglop>
 <1215497929.8970.207.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Paul Mackerras <paulus@au1.ibm.com>, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jul 2008, Benjamin Herrenschmidt wrote:
> On Tue, 2008-07-08 at 08:24 +1000, Benjamin Herrenschmidt wrote:
> > > There is a little inconsistency, that arch_calc_vm_prot_bits
> > > and arch_vm_get_page_prot just handle the exceptional flag (SAO),
> > > whereas arch_validate_prot handles all of them; but I don't feel
> > > so strongly about that to suggest resubmission.
> > > 
> > > And regarding VM_SAO added to include/linux/mm.h in 3/6: although
> > > it's odd to be weaving back and forth between arch-specific and
> > > common, it's already the case that mman definitions and pgtable
> > > definitions are arch-specific but mm.h common: I'm much happier
> > > to have VM_SAO defined once there as Dave has it, than get into
> > > arch-specific vm_flags.
> > > 
> > > Is someone going to be asking for PROT_WC shortly?
> > 
> > I'll definitely come with PROT_ENDIAN soon :-) (ie, some powerpc
> > processors can have a per-page endian flag that when set causes all
> > load/store instructions on this are to be byte-flipped, support for
> > this
> > feature has been requested for some time, and now I have the
> > infrastructure to do it).
> 
> BTW. Do we have your ack ?

To PROT_SAO?  Okay,
Acked-by: Hugh Dickins <hugh@veritas.com>

> 
> Andrew, what tree should this go via ? I have further powerpc patches
> depending on this one... so on one hand I'd be happy to take it, but
> on the other hand, it's more likely to clash with other things...
> 
> Maybe I should check how it applies on top of linux-next.
> 
> Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
