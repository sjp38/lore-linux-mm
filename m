Date: Fri, 4 Jul 2003 02:33:45 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030704013345.GA18928@mail.jlokier.co.uk>
References: <20030702233014.GW23578@dualathlon.random> <20030702235540.GK26348@holomorphy.com> <20030703113144.GY23578@dualathlon.random> <20030703114626.GP26348@holomorphy.com> <20030703125839.GZ23578@dualathlon.random> <20030703184825.GA17090@mail.jlokier.co.uk> <20030703185431.GQ26348@holomorphy.com> <20030703193328.GN23578@dualathlon.random> <20030703222113.GS26348@holomorphy.com> <20030704004641.GR23578@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030704004641.GR23578@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> so you agree it'd better be a separate syscall

Per-page protections might be workable just through mremap().  As you
say, it's just a matter of appropriate bits in the swap entry.  To
userspace it is a transparent performance improvement.

Unfortunately without an appropriate bit in the pte too, that
restricts per-page protections to work only with shared mappings, or
anon mappings which have not been forked, due to the lack of COW.  It
would still be a good optimisation, although it would be a shame if,
say, a GC implementation of malloc et al. (eg. Boehm's allocator)
would not be transparent over fork().

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
