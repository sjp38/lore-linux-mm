Date: Thu, 3 Jul 2003 15:21:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030703222113.GS26348@holomorphy.com>
References: <20030702222641.GU23578@dualathlon.random> <20030702231122.GI26348@holomorphy.com> <20030702233014.GW23578@dualathlon.random> <20030702235540.GK26348@holomorphy.com> <20030703113144.GY23578@dualathlon.random> <20030703114626.GP26348@holomorphy.com> <20030703125839.GZ23578@dualathlon.random> <20030703184825.GA17090@mail.jlokier.co.uk> <20030703185431.GQ26348@holomorphy.com> <20030703193328.GN23578@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030703193328.GN23578@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Jamie Lokier <jamie@shareable.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 03, 2003 at 11:54:31AM -0700, William Lee Irwin III wrote:
>> I call that application #2.

On Thu, Jul 03, 2003 at 09:33:28PM +0200, Andrea Arcangeli wrote:
> maybe I'm missing something but protections have nothing to do with
> remap_file_pages IMHO. That's all about teaching the swap code to
> reserve more bits in the swap entry and to store the protections there
> and possibly teaching the page fault not to get confused. It might
> prefer to use the populate callback too to avoid specializing the
> pte_none case, but I think the syscall should be different, and it
> shouldn't have anything to do with the nonlinearity (nor with rmap).

It's obvious what to do about protections.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
