Message-ID: <3D4DB712.BD3ED97C@zip.com.au>
Date: Sun, 04 Aug 2002 16:21:54 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: how not to write a search algorithm
References: <3D4CE74A.A827C9BC@zip.com.au> <E17bU7n-0000Yb-00@starship> <3D4DB2AF.48B07053@zip.com.au> <E17bUNx-0000aJ-00@starship>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: William Lee Irwin III <wli@holomorphy.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> 
> On Monday 05 August 2002 01:03, Andrew Morton wrote:
> > The list walk is killing us now.   I think we need:
> >
> > struct pte_chain {
> >       struct pte_chain *next;
> >       pte_t *ptes[L1_CACHE_BYTES/4 - 4];
> > };
> 
> Which list walk, the remove or the page_referenced?

The remove in this case.  I'll post some numbers
in the other thread.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
