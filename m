From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: page fault scalability patch V14 [3/7]: i386 universal cmpxchg
Date: Wed, 5 Jan 2005 12:51:34 +0100
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041136350.805@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501041136350.805@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200501051251.36879.zippel@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tuesday 04 January 2005 20:37, Christoph Lameter wrote:

>         * Provide emulation of cmpxchg suitable for uniprocessor if
>    build and run on 386.
>         * Provide emulation of cmpxchg8b suitable for uniprocessor
>    systems if build and run on 386 or 486.

I'm not sure that's such a good idea. This emulation is more expensive as it 
has to disable interrupts and you already have emulation functions using 
spinlocks anyway, so why not use them? This way your patch would not just 
scale up, but also still scale down.

bye, Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
