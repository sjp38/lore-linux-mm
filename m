Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.4.19 Vs 2.4.19-rmap14a with anonymous mmaped memory
Date: Mon, 26 Aug 2002 14:08:53 +0200
References: <Pine.LNX.4.44.0208252220030.31523-100000@skynet>
In-Reply-To: <Pine.LNX.4.44.0208252220030.31523-100000@skynet>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17jIfu-0001hg-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 26 August 2002 00:22, Mel Gorman wrote:
> 4 tests were run on each machine each related to anonymous memory used in
> a mmaped region. Two reference patterns were used. smooth_sin and
> smooth_sin-random . Both sets show a sin curve when the number of times
> each page is referenced is graphed (See the green line in the graph Pages
> Present/Swapped). With smooth_sin, the pages are reffered to in order.
> With smooth_sin-random, the pages are referenced in a random order but the
> amount of times a page is referenced.

Could you please provide pseudocode, to specify these reference patterns
more precisely?

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
