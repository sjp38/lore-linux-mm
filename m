Date: Wed, 10 Jul 2002 10:32:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <20020710173254.GS25360@holomorphy.com>
References: <20810000.1026311617@baldur.austin.ibm.com> <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0207101213480.14432-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 10, 2002 at 12:18:12PM -0300, Rik van Riel wrote:
> I like it.  This patch seems ready for merging, as soon as
> we've gotten rmap in.
> Speaking of getting rmap in ... we might need some arguments
> to get this thing past Linus, anyone ? ;)

In no particular order:

(1)  page replacement no longer goes around randomly unmapping things
(2)  referenced bits are more accurate because there aren't several ms
	or even seconds between find the multiple pte's mapping a page
(3)  reduces page replacement from O(total virtually mapped) to O(physical)
(4)  enables defragmentation of physical memory
(5)  enables cooperative offlining of memory for friendly guest instance
	behavior in UML and/or LPAR settings
(6)  demonstrable benefit in performance of swapping which is common in
	end-user interactive workstation workloads (I don't like the word
	"desktop"). c.f. Craig Kulesa's post wrt. swapping performance
(7)  evidence from 2.4-based rmap trees indicates approximate parity
	with mainline in kernel compiles with appropriate locking bits
(8)  partitioning of physical memory can reduce the complexity of page
	replacement searches by scanning only the "interesting" zones
	implemented and merged in 2.4-based rmap
(9)  partitioning of physical memory can increase the parallelism of page
	replacement searches by independently processing different zones
	implemented, but not merged in 2.4-based rmap
(10) the reverse mappings may be used for efficiently keeping pte cache
	attributes coherent
(11) they may be used for virtual cache invalidation (with changes)
(12) the reverse mappings enable proper RSS limit enforcement
	implemented and merged in 2.4-based rmap

Hmm, anything else?


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
