Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 16:45:38 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <3D2C9288.51BBE4EB@zip.com.au> <20020710222210.GU25360@holomorphy.com>
In-Reply-To: <20020710222210.GU25360@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TO9S-0003JO-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@zip.com.au>
Cc: Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 11 July 2002 00:22, William Lee Irwin III wrote:
> As far as operating regions for page replacement go I see 3 obvious ones:
> (1) lots of writeback with no swap
> (2) churning clean pages with no swap
> (3) swapping

Another big variable is the balance of streaming IO versus program workload.
Within streaming IO there is the read/write balance (starting to get away 
from core VM here).  There's also the balance of file cache activity vs
anonymous memory.  It goes on of course - we have to boil this down to a few 
reasonably orthogonal variables.

Your specific load examples can be thought of as specific points in a 
two-dimensional test model with two variables:

  - Total working set relative to physical memory (should range from 
    significantly less to significantly more)

  - Balance of read accesses vs write accesses

Adding up the above, there are 5 knobs to turn so far.  This whole thing 
sounds like it can be modeled elegantly by a couple of C programs, one to 
generate memory loads and another to generate file loads, or we may be able 
to identify an off-the-shelf benchmark program that provides some of the 
tunables we need.

Needless to say, we need more than one or two points on each axis.  We need 
to capture our data in some organized way.  How?

Clearly, this benchmarking project as I've described it is starting to blow 
up into unreasonable dimensions.  I'd like to return to the idea of going 
through the original list of advantages and disadvantages item by item and 
identifying exactly which variables in our complete test space are relevant.  
This lets us set the knobs on our test programs, define the test, and know 
which numbers we want to capture/graph.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
