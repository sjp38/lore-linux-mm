Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 15:41:16 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <20020710173254.GS25360@holomorphy.com> <3D2C9288.51BBE4EB@zip.com.au>
In-Reply-To: <3D2C9288.51BBE4EB@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TN9A-0003Ie-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 10 July 2002 22:01, Andrew Morton wrote:
> Bill, please throw away your list and come up with a new one.
> Consisting of workloads and tests which we can run to evaluate
> and optimise page replacement algorithms.

I liked the list, I think it just needs to be reorganized.  All the
vaporware needs to go into an "enables" section (repeating myself)
and it needs to aquire a 'disadvantages' section, under which I'd
like to contribute:

  - For pure computational loads with no swapping, incurs unavoidable)
    overhead on page setup and teardown

       (measure it)

  - Adds new struct page overhead of one word, plus two words per
    shared pte (share > 1)

       (measure this)

  - Introduces a new resource, pte chain nodes, with associated
    locks and management issues

       (show locking profiles)

  - Is thought to cause swap read fragmentation

       (demonstrate this, if possible)

And an advantage to add to Bill's 'enables' list:

  - Enables a swap fragmentation reduction algorithm based
    on finding virtually adjacent swapout candidates via the
    pte_chains

> Alternatively, please try to enumerate the `operating regions'
> for the page replacement code.  Then, we can identify measurable
> tests which exercise them.  Then we can identify combinations of
> those tests to model a `workload'.    We need to get this ball
> rolling somehow.

Strongly agreed that the focus has to be on workload modeling.
We should be able to organize the modeling strictly around the
advantages/disadvantages list.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
