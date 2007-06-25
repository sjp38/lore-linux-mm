Date: Mon, 25 Jun 2007 23:12:59 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: 2.6.22-rc5-yesterdaygit with VM debug: BUG in mm/rmap.c:66: anon_vma_link ?
Message-ID: <20070625211259.GD7059@v2.random>
References: <467F6882.9000800@vmware.com> <Pine.LNX.4.64.0706252129430.22492@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706252129430.22492@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Petr Vandrovec <petr@vmware.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 25, 2007 at 10:05:09PM +0100, Hugh Dickins wrote:
> size of memory?); but I rather think validate_anon_vma has outlived its
> usefulness, and is better just removed - which gives a magnificent

Probably yes. But the most fundamental issue is that this code
probably was never meant to be enabled through a menuconfig tweak but
only by editing the source.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
