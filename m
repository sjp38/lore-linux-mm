Date: Thu, 3 Jul 2003 21:33:28 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030703193328.GN23578@dualathlon.random>
References: <20030702221551.GH26348@holomorphy.com> <20030702222641.GU23578@dualathlon.random> <20030702231122.GI26348@holomorphy.com> <20030702233014.GW23578@dualathlon.random> <20030702235540.GK26348@holomorphy.com> <20030703113144.GY23578@dualathlon.random> <20030703114626.GP26348@holomorphy.com> <20030703125839.GZ23578@dualathlon.random> <20030703184825.GA17090@mail.jlokier.co.uk> <20030703185431.GQ26348@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030703185431.GQ26348@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Jamie Lokier <jamie@shareable.org>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 03, 2003 at 11:54:31AM -0700, William Lee Irwin III wrote:
> Andrea Arcangeli wrote:
> >> but I didn't hear any emulator developer ask for this feature yet
> 
> On Thu, Jul 03, 2003 at 07:48:25PM +0100, Jamie Lokier wrote:
> > No, but there was a meek request to get writable/read-only protection
> > working with remap_file_pages, so that a garbage collector can change
> > protection on individual pages without requiring O(nr_pages) vmas.
> > Perhaps that should have nothing to do with remap_file_pages, though.
> 
> I call that application #2.

maybe I'm missing something but protections have nothing to do with
remap_file_pages IMHO. That's all about teaching the swap code to
reserve more bits in the swap entry and to store the protections there
and possibly teaching the page fault not to get confused. It might
prefer to use the populate callback too to avoid specializing the
pte_none case, but I think the syscall should be different, and it
shouldn't have anything to do with the nonlinearity (nor with rmap).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
