Date: Thu, 13 Jan 2005 12:39:54 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050113203954.GA6101@holomorphy.com>
References: <20050113202642.68138.qmail@web14325.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050113202642.68138.qmail@web14325.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2005 at 12:26:42PM -0800, Kanoj Sarcar wrote:
> The second question is that even though truncate_count
> is declared atomic (ie probably volatile on most
> architectures), that does not make gcc guarantee
> anything in terms of ordering, right?
> Finally, does anyone really believe that a smp_rmb()
> is required in step 2? My logic is that nopage() is
> guaranteed to grab/release (spin)locks etc as part of
> its processing, and that would force the snapshots of
> truncate_count to be properly ordered.

spin_unlock() does not imply a memory barrier. e.g. on ia32 it's
not even an atomic operation.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
