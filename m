Date: Fri, 22 Oct 2004 03:22:11 +0200
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-ID: <20041022012211.GD14325@dualathlon.random>
References: <1098393346.7157.112.camel@localhost> <20041021144531.22dd0d54.akpm@osdl.org> <20041021223613.GA8756@dualathlon.random> <20041021160233.68a84971.akpm@osdl.org> <20041021232059.GE8756@dualathlon.random> <20041021164245.4abec5d2.akpm@osdl.org> <20041022003004.GA14325@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041022003004.GA14325@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2004 at 02:30:04AM +0200, Andrea Arcangeli wrote:
> If you want to shootdown ptes before clearing the bitflag, that's fine

small correction s/before/after/. doing the pte shootdown before
clearing the uptodate bitflag, would still not guarantee to read
uptodate data after the invalidate (a minor page fault could still
happen between the shootdown and the clear_bit; while after clearing the
uptodate bit a major fault hitting the disk and refreshing the pagecache
contents will be guaranteed - modulo bhs, well at least nfs is sure ok
in that respect ;).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
