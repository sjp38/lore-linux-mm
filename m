Date: Fri, 14 Jan 2005 13:02:28 +0100 (CET)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <20050114041421.GA41559@muc.de>
Message-ID: <Pine.LNX.4.61.0501141255130.30794@scrub.home>
References: <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de>
 <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com>
 <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org>
 <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com>
 <20050112104326.69b99298.akpm@osdl.org> <Pine.LNX.4.58.0501121055490.11169@schroedinger.engr.sgi.com>
 <41E73EE4.50200@linux-m68k.org> <20050114041421.GA41559@muc.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 14 Jan 2005, Andi Kleen wrote:

> > But there might be a loss in the UP case. Spinlocks are optimized away, 
> > but your cmpxchg emulation enables/disables interrupts with every access.
> 
> Only for 386s and STI/CLI is quite cheap there.

But it's still not free and what about other archs? Why not just check 
__HAVE_ARCH_CMPXCHG and provide a replacement, which is guaranteed cheaper 
if no interrupt synchronisation is needed. 

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
