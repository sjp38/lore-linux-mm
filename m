Date: Wed, 19 Jun 2002 13:09:23 -0700 (MST)
From: Craig Kulesa <ckulesa@as.arizona.edu>
Subject: Re: [PATCH] (2/2) reverse mappings for current 2.5.23 VM
In-Reply-To: <E17Kiio-0000sO-00@starship>
Message-ID: <Pine.LNX.4.44.0206191248190.4292-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Daniel Phillips wrote:

> You might conclude from the above that the lru+rmap is superior to 
> aging+rmap: while they show the same wall-clock time, lru+rmap consumes 
> considerably less disk bandwidth.  

I wouldn't draw _any_ conclusions about either patch yet, because as you 
said, it's only one type of load.  And it was a single tick in vmstat 
where page_launder() was aggressive that made the difference between the 
two.  In a different test, where I had actually *used* more of the 
application pages instead of simply closing most of the applications 
(save one, the memory hog), the results are likely to have been very 
different.  

I think that Rik's right: this simply points out that page_launder(), at 
least in its interaction with 2.5, needs some tuning.  I think both 
approaches look very promising, but each for different reasons.  

-Craig

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
