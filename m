Date: Wed, 24 Apr 2002 11:31:18 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020424183118.GF26092@holomorphy.com>
References: <Pine.LNX.4.44L.0204241152100.7447-100000@duckman.distro.conectiva> <873cxlunym.fsf@fadata.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <873cxlunym.fsf@fadata.bg>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Momchil Velikov <velco@fadata.bg>
Cc: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Rik" == Rik van Riel <riel@conectiva.com.br> writes:
> Rik> So how do you run a pmap VM without duplicating the data from
> Rik> the pmap layer into the page tables ?
> Rik> Remember that for VM info the page tables -are- the radix tree.

On Wed, Apr 24, 2002 at 06:16:01PM +0300, Momchil Velikov wrote:
> And the page tables -are- the pmap layer :)

Yes and no; pagetables-as-ADT normally hides the structure and provides
a canned set of operations on them. Linux just standardizes the data
structure and open-codes access to them in generic code.

One could conceive of a pmap/HAT/whatever -like layer that did little
more than break off copy_page_range(), zap_page_range(), and a few
others into their own file and rename them. At that point it's too
minor of a change to warrant actually carrying it through, unless
one is particularly concerned about radix tree walking obscuring
other operations with actual semantic content. (And it's unclear that
it would get very good coverage on that front anyway.)


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
