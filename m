Date: Tue, 7 May 2002 12:50:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <20020507195007.GW15756@holomorphy.com>
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva> <20020507192547.GU15756@holomorphy.com> <E175Avp-0000Tm-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E175Avp-0000Tm-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 May 2002 21:25, William Lee Irwin III wrote:
>> Procedural interfaces to pagetable manipulations are largely what
>> the BSD pmap and SVR4 HAT layers consisted of, no?

On Tue, May 07, 2002 at 09:47:28PM +0200, Daniel Phillips wrote:
> They factor the interface the wrong way for Linux.  You don't want
> to have to search for each (pte *) starting from the top of the
> structure.  We need to be able to do bulk processing.  The BSD
> interface just doesn't accomodate this.

Generally the way to achieve this is by anticipating those bulk
operations and providing standardized methods for them. copy_page_range()
and zap_page_range() are already examples of this. For other cases,
it's perhaps a useful layer inversion.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
