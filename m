Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH] (2/2) reverse mappings for current 2.5.23 VM
Date: Wed, 19 Jun 2002 22:44:06 +0200
References: <Pine.LNX.4.44.0206191248190.4292-100000@loke.as.arizona.edu>
In-Reply-To: <Pine.LNX.4.44.0206191248190.4292-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17KmJC-0000xN-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 19 June 2002 22:09, Craig Kulesa wrote:
> I wouldn't draw _any_ conclusions about either patch yet, because as you 
> said, it's only one type of load.  And it was a single tick in vmstat 
> where page_launder() was aggressive that made the difference between the 
> two.  In a different test, where I had actually *used* more of the 
> application pages instead of simply closing most of the applications 
> (save one, the memory hog), the results are likely to have been very 
> different.  
> 
> I think that Rik's right: this simply points out that page_launder(), at 
> least in its interaction with 2.5, needs some tuning.  I think both 
> approaches look very promising, but each for different reasons.  

Indeed.

One reason for being interested in a lot more numbers and a variety of loads 
is that there's an effect, predicted by Andea, that I'm watching for:  both 
aging+rmap and lru+rmap do swapout in random order with respect to virtual 
memory, and this should in theory cause increased seeking on swap-in.  We 
didn't see any sign of such degradation vs mainline, in fact we saw a 
significant overall speedup.  It could be we just haven't got enough data 
yet, or maybe there really is more seeking for each swap-in, but the effect 
of less swapping overall is dominant.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
