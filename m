Date: Sun, 4 Aug 2002 16:00:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: how not to write a search algorithm
Message-ID: <20020804230007.GJ4010@holomorphy.com>
References: <3D4CE74A.A827C9BC@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au> <E17bU7n-0000Yb-00@starship> <3D4DB2AF.48B07053@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D4DB2AF.48B07053@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: Daniel Phillips <phillips@arcor.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 04, 2002 at 04:03:11PM -0700, Andrew Morton wrote:
> The list walk is killing us now.   I think we need:
> struct pte_chain {
> 	struct pte_chain *next;
> 	pte_t *ptes[L1_CACHE_BYTES/4 - 4];
> };
> Still poking...

Could I get a

pte_t *ptes[(L1_CACHE_BYTES - sizeof(struct pte_chain *))/(sizeof(pte_t *))] ?

Well, regardless, the mean pte_chain length for chains of length > 1 is
around 6, and the std. dev. is around 12, and the distribution is *very*
long-tailed, so this is just about guaranteed to help at the cost of some
slight internal fragmentation.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
