Date: Fri, 29 Oct 2004 00:46:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
Message-ID: <20041029074607.GA12934@holomorphy.com>
References: <4181EF2D.5000407@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4181EF2D.5000407@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2004 at 05:20:13PM +1000, Nick Piggin wrote:
> Known issues: Hugepages, nonlinear pages haven't been looked at
> and are quite surely broken. TLB flushing (gather/finish) runs
> without the page table lock, which will break at least SPARC64.
> Additional atomic ops in copy_page_range slow down lmbench fork
> by 7%.

This raises the rather serious question of what you actually did
besides rearranging Lameter's code. It had all the same problems;
resolving them is a prerequisite to going anywhere with all this.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
