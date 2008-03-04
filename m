Date: Tue, 4 Mar 2008 13:44:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
In-Reply-To: <47CDB498.6040003@cs.helsinki.fi>
Message-ID: <Pine.LNX.4.64.0803041344120.20033@schroedinger.engr.sgi.com>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
 <47CD4AB3.3080409@linux.vnet.ibm.com> <20080304103636.3e7b8fdd.akpm@linux-foundation.org>
 <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie>
 <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
 <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI>
 <Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com>
 <20080304123459.364f879b.akpm@linux-foundation.org> <47CDB498.6040003@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, mel@csn.ul.ie, kamalesh@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org, apw@shadowen.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Pekka Enberg wrote:

> Looking at the code, it's triggerable in 2.6.24.3 at least. Why we don't have
> a report yet, probably because (1) the default allocator is SLUB which doesn't
> suffer from this and (2) you need a big honkin' NUMA box that causes fallback
> allocations to happen to trigger it.

Plus the issue only became a problem after the antifrag stuff went in. 
That came with SLUB as the default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
