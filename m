Date: Thu, 16 Dec 2004 19:31:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
 tests
In-Reply-To: <20041212212456.GB2714@holomorphy.com>
Message-ID: <Pine.LNX.4.58.0412161931010.11341@schroedinger.engr.sgi.com>
References: <41BBF923.6040207@yahoo.com.au>
 <Pine.LNX.4.44.0412120914190.3476-100000@localhost.localdomain>
 <20041212212456.GB2714@holomorphy.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Dec 2004, William Lee Irwin III wrote:

> On Sun, Dec 12, 2004 at 09:33:11AM +0000, Hugh Dickins wrote:
> > Oh, hold on, isn't handle_mm_fault's pmd without page_table_lock
> > similarly racy, in both the 64-on-32 cases, and on architectures
> > which have a more complex pmd_t (sparc, m68k, h8300)?  Sigh.
>
> yes.

Those may fall back to use the page_table_lock for individual operations
that cannot be realized in an atomic way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
