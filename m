Date: Sat, 21 Sep 2002 17:08:17 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: overcommit stuff
Message-ID: <16785326.1032628095@[10.10.2.3]>
In-Reply-To: <3D8D08B7.419DD093@digeo.com>
References: <3D8D08B7.419DD093@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> "It" being vm_committed_space.
> 
> The problem is that it's read from frequently, as well as
> updated frequently.  So we would still have problems when
> we have to reach across and fish the cpu-local counters
> out of remote corners of the machine all the time.

Not if you set overcommit = 1, as far as I can see.

> The usual tricks for amortising this counter's cost have (serious)
> accuracy implications.

Well, seems it's a rough guess anyway ... at least it's vastly
inaccurate in one direction (pessimistic).
 
> I am planning on sitting down and working out exactly what we're
> trying to account here - presumably there's another way.  Just
> havent got onto it yet.
> 
> Worst come to worst, we can hide it inside CONFIG_NOT_WHACKOMATIC
> I guess.

I was thinking of moving the update in vm_enough_memory under
the switch for what type of overcommit you had, and doing something
similar for the other places it's updated. I suppose that would do
unfortunate things if you turned overcommit from 1 to something
else whilst the system was running though ... not convinced that's
a good idea anyway OTOH.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
