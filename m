Date: Wed, 10 Jul 2002 13:33:53 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [PATCH] Optimize out pte_chain take three
Message-ID: <9560000.1026333233@flay>
In-Reply-To: <Pine.LNX.4.44L.0207101712120.14432-100000@imladris.surriel.com>
References: <Pine.LNX.4.44L.0207101712120.14432-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Bill, please throw away your list and come up with a new one.
>> Consisting of workloads and tests which we can run to evaluate
>> and optimise page replacement algorithms.
> 
> Agreed, we do want nice stuff building on rmap, but
> Linus has indicated that he doesn't want it in the
> first stage of merging rmap.
> 
> Any way out of this chicken&egg situation ?

Surely we can just get the benchmarking done on the full set of patches 
before any part of them gets accepted into mainline? I don't see what the 
problem is ....

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
