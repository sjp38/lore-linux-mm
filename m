Date: Sun, 12 Dec 2004 13:24:56 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance tests
Message-ID: <20041212212456.GB2714@holomorphy.com>
References: <41BBF923.6040207@yahoo.com.au> <Pine.LNX.4.44.0412120914190.3476-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0412120914190.3476-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Dec 12, 2004 at 09:33:11AM +0000, Hugh Dickins wrote:
> Oh, hold on, isn't handle_mm_fault's pmd without page_table_lock
> similarly racy, in both the 64-on-32 cases, and on architectures
> which have a more complex pmd_t (sparc, m68k, h8300)?  Sigh.

yes.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
