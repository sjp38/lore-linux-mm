Date: Tue, 28 Jun 2005 07:19:03 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch 2] mm: speculative get_page
Message-ID: <20050628141903.GR3334@holomorphy.com>
References: <42C0AAF8.5090700@yahoo.com.au> <20050628040608.GQ3334@holomorphy.com> <42C0D717.2080100@yahoo.com.au> <20050627.220827.21920197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050627.220827.21920197.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 27, 2005 at 10:08:27PM -0700, David S. Miller wrote:
> BTW, I disagree with this assertion.  spin_unlock() does imply a
> memory barrier.
> All memory operations before the release of the lock must execute
> before the lock release memory operation is globally visible.

The affected architectures have only recently changed in this regard.
ppc64 was the most notable case, where it had a barrier for MMIO
(eieio) but not a general memory barrier. PA-RISC likewise formerly had
no such barrier and was a more normal case, with no barrier whatsoever.

Both have since been altered, ppc64 acquiring a heavyweight sync
(arch nomenclature), and PA-RISC acquiring 2 memory barriers.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
