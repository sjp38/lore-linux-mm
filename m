Date: Thu, 13 Jan 2005 09:14:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page table lock patch V15 [0/7]: overview
In-Reply-To: <41E5EF2B.3050105@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0501130912000.18742@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0501130258210.4577-100000@localhost.localdomain>
 <41E5EF2B.3050105@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, ak@muc.de, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2005, Nick Piggin wrote:

> I'm still not too sure that all places read the pte atomically where needed.
> But presently this is not a really big concern because it only would
> really slow down i386 PAE if anything.

S/390 is also affected. And I vaguely recall special issues with sparc
too. That is why I dropped the arch support for that a long time ago from
the patchset. Then there was some talk a couple of months back to use
another addressing mode on IA64 that may also require 128 bit ptes. There
are significantly different ways of doing optimal SMP locking for these
scenarios.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
