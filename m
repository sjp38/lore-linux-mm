Received: from cesarb by flower.cesarb.personal with local (Exim 3.12 #1 (Debian))
	id 13Nnul-0002Nc-00
	for <linux-mm@kvack.org>; Sat, 12 Aug 2000 23:54:19 -0300
Date: Sat, 12 Aug 2000 23:54:19 -0300
Subject: RoShamBo and Linux MM
Message-ID: <20000812235419.A9081@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm not a MM developer, and I don't understand much of the subject; I'm sending
this so you can tell me where I'm wrong =)

The RoShamBo Programming Competition is a contest of the popular
Rock-Paper-Scissors game, in which a program has to guess what the other
program will chose, and then play the right option to beat the opponent. The
opponent, of course, will try to do the same. Its page is
http://www.cs.ualberta.ca/~darse/rsbpc.html

The "ideal" strategy in a game theory sense is to do all your choices randomly,
so you will have an equal chance of winning or losing.

However, your opponents are not all random. To make things more interesting,
some of your opponents will be bots designed to use simple strategies, like a
constant 0-1-2-0-1-2-0-1-2, a distribution based on the digits of pi, or in the
contest announcement text. Other bots do simple things like playing the last
move of the opponent.

So, how does that relate to VM? Imagine you have a set of n pages, and you have
to chose one to swap out:

        0-1-2-3-4-5-6-7-8-...-n

You also have an history of accesses to the pages:

time
   0    0-1-2-3-4-5-a-7-8-...-n
   1    0-a-2-3-4-5-6-7-8-...-n
   2    0-1-a-3-4-5-6-7-8-...-n
   .
   .
   .
   t    0-1-2-3-a-5-6-7-8-...-n

You are now at time t+1.

This is like the RoShamBo game, but with n choices instead of 3, and with your
objective being to find the page with the least likelihood of being accessed
sooner. Notice that I'm not removing the swapped-out pages from the statistics.

A predictor would have to do some kinds of prediction that the contestants on
that contest had to do. Basically, in the RoShamBo contest, you had to find a
pattern in the opponent's behavior; in the VM problem, you have to find a
pattern in the memory accesses. You have the advantage of the "opponent" not
trying to outsmart you, tough.

So, I think that by looking at the players in that contest, we might gain some
insight in how to design a swap-out algorithm.

Comments?

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
