Date: Mon, 2 Apr 2007 16:02:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 2/2] i386 arch page size slab fixes
In-Reply-To: <20070402230051.GI2986@holomorphy.com>
Message-ID: <Pine.LNX.4.64.0704021601220.2481@schroedinger.engr.sgi.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
 <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
 <20070402230051.GI2986@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, William Lee Irwin III wrote:

> This doesn't quite cover all bases. The changes to pageattr.c and
> fault.c are dubious and need verification at the very least. They were
> largely slapped together to get the files past the compiler for the
> performance comparisons that were never properly done.

I looked through them but then I am no i386 specialist though. Looked 
fine.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
