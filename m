Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] Optimize out pte_chain take three
Date: Sat, 13 Jul 2002 15:55:32 +0200
References: <20810000.1026311617@baldur.austin.ibm.com> <E17TMqy-0003IY-00@starship> <20020713133058.GU23693@holomorphy.com>
In-Reply-To: <20020713133058.GU23693@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17TNN4-0003Iw-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Saturday 13 July 2002 15:30, William Lee Irwin III wrote:
> On Sat, Jul 13, 2002 at 03:22:28PM +0200, Daniel Phillips wrote:
> > See "enables" above.  Though I agree we want the thing at parity or
> > better on its own merits, I don't see the point of throwing tomatoes at
> > the "enables" points.  Recommendation: separate the list into "improves"
> > and "enables".
> 
> The direction has been set and I'm following it. These things are now
> off the roadmap entirely regardless, or at least I won't pursue them
> until the things needing to be done now are addressed.

> Say, we could use a number of helpers with the quantitative measurement
> effort, Is there any chance you could help out here as well?

Forget it :-)

I'll help with the test design.  We have a bunch of people ready to do
the work on the actual benchmarking.  We need to provide precise statements
of the test model, and put out a call for testers.  I'll help with that
too.

> It'd certainly help get the cost/benefit analysis of rmap going for the
> merge, and maybe even pinpoint things needing to be addressed.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
