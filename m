Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Wed, 8 May 2002 01:02:02 +0200
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <E175Avp-0000Tm-00@starship> <20020507195007.GW15756@holomorphy.com>
In-Reply-To: <20020507195007.GW15756@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175Dy8-0000U6-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 21:50, William Lee Irwin III wrote:
> On Tuesday 07 May 2002 21:25, William Lee Irwin III wrote:
> >> Procedural interfaces to pagetable manipulations are largely what
> >> the BSD pmap and SVR4 HAT layers consisted of, no?
> 
> On Tue, May 07, 2002 at 09:47:28PM +0200, Daniel Phillips wrote:
> > They factor the interface the wrong way for Linux.  You don't want
> > to have to search for each (pte *) starting from the top of the
> > structure.  We need to be able to do bulk processing.  The BSD
> > interface just doesn't accomodate this.
> 
> Generally the way to achieve this is by anticipating those bulk
> operations and providing standardized methods for them. copy_page_range()
> and zap_page_range() are already examples of this. For other cases,
> it's perhaps a useful layer inversion.

What I'm really talking about is how you'd reimplement copy_page_range,
zap_page_range, and the other 4-5 primitives that use the 3 nested loops
style of traversing the i86-style page table structure.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
