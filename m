Message-ID: <401859CB.2040200@cyberone.com.au>
Date: Thu, 29 Jan 2004 11:54:35 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: Memory Management in 2.6
References: <20040127162346.37b75f6c.cliffw@osdl.org> <40185564.8020709@cyberone.com.au>
In-Reply-To: <40185564.8020709@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <Nikita@Namesys.COM>, Roger Luethi <rl@hellgate.ch>
List-ID: <linux-mm.kvack.org>

Hi,

I have done a bit more benchmarking with Nikita's patch
dont-rotate-active-list (I call it -lru, sorry), and my
mapped pages fairness patch.

Together they're nearly twice as fast as the standard VM
under heavier make loads, which is pleasing.

http://www.kerneltrap.org/~npiggin/vm/2/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
