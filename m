Date: Fri, 24 Jan 2003 18:26:48 -0800
From: Larry McVoy <lm@bitmover.com>
Subject: Re: your mail
Message-ID: <20030125022648.GA13989@work.bitmover.com>
References: <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com> <40475.210.212.228.78.1043384883.webmail@mail.nitc.ac.in> <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com> <3.0.6.32.20030124212935.007fcc10@boo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3.0.6.32.20030124212935.007fcc10@boo.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Papadopoulos <jasonp@boo.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> For the record, I finally got to try my own page coloring patch on a 1GHz
> Athlon Thunderbird system with 256kB L2 cache. With the present patch, my
> own number crunching benchmarks and a kernel compile don't show any benefit 
> at all, and lmbench is completely unchanged except for the mmap latency, 
> which is slightly worse. Hardly a compelling case for PCs!

If it works correctly then the variability in lat_ctx should go away.
Try this

	for p in 2 4 8 12 16 24 32 64
	do	for size in 0 2 4 8 16
		do	for i in 1 2 3 4 5 6 7 8 9 0
			do	lat_ctx -s$size $p
			done
		done
	done

on both the with and without kernel.  The page coloring should make the 
numbers rock steady, without it, they will bounce a lot.
-- 
---
Larry McVoy            	 lm at bitmover.com           http://www.bitmover.com/lm 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
