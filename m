Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Why *not* rmap, anyway?
Date: Wed, 8 May 2002 16:33:45 +0200
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol> <E175Avp-0000Tm-00@starship> <87n0vbrrxr.fsf@fadata.bg>
In-Reply-To: <87n0vbrrxr.fsf@fadata.bg>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E175SVl-0003na-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Momchil Velikov <velco@fadata.bg>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 08 May 2002 09:59, Momchil Velikov wrote:
> >>>>> "Daniel" == Daniel Phillips <phillips@bonn-fries.net> writes:
> 
> Daniel> On Tuesday 07 May 2002 21:25, William Lee Irwin III wrote:
> >> Procedural interfaces to pagetable manipulations are largely what
> >> the BSD pmap and SVR4 HAT layers consisted of, no?
> 
> Daniel> They factor the interface the wrong way for Linux.  You don't want
> Daniel> to have to search for each (pte *) starting from the top of the
> Daniel> structure.  We need to be able to do bulk processing.  The BSD
> Daniel> interface just doesn't accomodate this.
> 
> FWIW, UVM has a mechanism to traverse all the mapped pages, as opposed
> to traversing all the addresses and checking of there is a page.

To make this concrete, what would copy_page_range look like, using this
mechanism?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
