Date: Thu, 3 Jul 2003 15:32:47 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: What to expect with the 2.6 VM
In-Reply-To: <20030703192750.GM23578@dualathlon.random>
Message-ID: <Pine.LNX.4.44.0307031531460.2785-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jul 2003, Andrea Arcangeli wrote:

> that's the very old exploit that touches 1 page per pmd.

> if you can't use a sane design it's not a kernel issue.

Agreed, the kernel shouldn't have to go out of its way to
give these applications good performance.  On the other
hand, I think the kernel should be able to _survive_
applications like this, reclaiming page tables when needed.

-- 
Great minds drink alike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
