Subject: Re: Why *not* rmap, anyway?
References: <Pine.LNX.4.33.0205071625570.1579-100000@erol>
	<Pine.LNX.4.44L.0205071620270.7447-100000@duckman.distro.conectiva>
	<20020507192547.GU15756@holomorphy.com> <E175Avp-0000Tm-00@starship>
From: Momchil Velikov <velco@fadata.bg>
In-Reply-To: <E175Avp-0000Tm-00@starship>
Date: 08 May 2002 10:59:12 +0300
Message-ID: <87n0vbrrxr.fsf@fadata.bg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, Christian Smith <csmith@micromuse.com>, Joseph A Knapka <jknapka@earthlink.net>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Daniel" == Daniel Phillips <phillips@bonn-fries.net> writes:

Daniel> On Tuesday 07 May 2002 21:25, William Lee Irwin III wrote:
>> Procedural interfaces to pagetable manipulations are largely what
>> the BSD pmap and SVR4 HAT layers consisted of, no?

Daniel> They factor the interface the wrong way for Linux.  You don't want
Daniel> to have to search for each (pte *) starting from the top of the
Daniel> structure.  We need to be able to do bulk processing.  The BSD
Daniel> interface just doesn't accomodate this.

FWIW, UVM has a mechanism to traverse all the mapped pages, as opposed
to traversing all the addresses and checking of there is a page.

My 2c,
-velco
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
