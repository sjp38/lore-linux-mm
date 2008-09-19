Subject: Re: Populating multiple ptes at fault time
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <48D17E75.80807@redhat.com>
References: <48D142B2.3040607@goop.org>  <48D17E75.80807@redhat.com>
Content-Type: text/plain
Date: Fri, 19 Sep 2008 10:45:03 -0700
Message-Id: <1221846303.8077.27.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-17 at 15:02 -0700, Avi Kivity wrote:
> Jeremy Fitzhardinge wrote:
> > Minor faults are easier; if the page already exists in memory, we should
> > just create mappings to it.  If neighbouring pages are also already
> > present, then we can can cheaply create mappings for them too.
> >
> >   
> 
> One problem is the accessed bit.  If it's unset, the shadow code cannot 
> make the pte present (since it has to trap in order to set the accessed 
> bit); if it's set, we're lying to the vm.
> 
> This doesn't affect Xen, only kvm.

Other archs too. On powerpc, !accessed -> not hashed (or not in the TLB
for SW loaded TLB platforms). 

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
