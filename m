Date: Sat, 25 Jan 2003 15:10:50 -0800
From: Larry McVoy <lm@bitmover.com>
Subject: Re: your mail
Message-ID: <20030125231050.GA21095@work.bitmover.com>
References: <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com> <40475.210.212.228.78.1043384883.webmail@mail.nitc.ac.in> <Pine.LNX.4.44.0301232104440.10187-100000@dlang.diginsite.com> <3.0.6.32.20030124212935.007fcc10@boo.net> <20030125022648.GA13989@work.bitmover.com> <m17kctceag.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m17kctceag.fsf@frodo.biederman.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Larry McVoy <lm@bitmover.com>, Jason Papadopoulos <jasonp@boo.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I am wondering if there is any point in biasing page addresses in between
> processes so that processes are less likely to have a cache conflict.
> i.e.  process 1 address 0 %16K == 0, process 2 address 0 %16K == 4K 

All good page coloring implementation do exactly that.  The starting
index into the page buckets is based on process id.
-- 
---
Larry McVoy            	 lm at bitmover.com           http://www.bitmover.com/lm 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
