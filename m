Date: Wed, 10 Jul 2002 17:14:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Optimize out pte_chain take three
In-Reply-To: <3D2C9288.51BBE4EB@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0207101712120.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 10 Jul 2002, Andrew Morton wrote:

> Vapourware

On request. Linus has indicated that he doesn't _want_
all of the rmap stuff at once, but just the mechanism.

> Bill, please throw away your list and come up with a new one.
> Consisting of workloads and tests which we can run to evaluate
> and optimise page replacement algorithms.

Agreed, we do want nice stuff building on rmap, but
Linus has indicated that he doesn't want it in the
first stage of merging rmap.

Any way out of this chicken&egg situation ?

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
