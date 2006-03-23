Received: by wproxy.gmail.com with SMTP id 68so721647wra
        for <linux-mm@kvack.org>; Thu, 23 Mar 2006 10:48:49 -0800 (PST)
Date: Thu, 23 Mar 2006 19:48:32 +0100
From: Diego Calleja <diegocg@gmail.com>
Subject: Re: [PATCH 00/34] mm: Page Replacement Policy Framework
Message-Id: <20060323194832.d9f153a3.diegocg@gmail.com>
In-Reply-To: <Pine.LNX.4.64.0603231003390.26286@g5.osdl.org>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
	<20060322145132.0886f742.akpm@osdl.org>
	<20060323205324.GA11676@dmt.cnet>
	<Pine.LNX.4.64.0603231003390.26286@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: marcelo.tosatti@cyclades.com, akpm@osdl.org, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@hp.com, iwamoto@valinux.co.jp, christoph@lameter.com, wfg@mail.ustc.edu.cn, npiggin@suse.de, riel@redhat.com
List-ID: <linux-mm.kvack.org>

El Thu, 23 Mar 2006 10:15:47 -0800 (PST),
Linus Torvalds <torvalds@osdl.org> escribio:

> IOW, just under half a _gigabyte_ of RAM is apparently considered to be 
> low end, and this is when talking about low-end (modern) hardware!

If it's considered "low-end" it's because people actually uses that
memory for something and the system starts swapping, not because it's
trendy.

The "powerful machines who never swaps" are always a minority. Being geeks
as we are we try to have the greatest machine possible, but the vast majority
of real users are "underpowered" I'm not talking of pentium 1 stuff, I can bet
there're far more pentium 4 machines with 256 MB out there than with 1 GB.

I know you don't hit those problems because you use expensive machines
with lots of ram ;) But in the _real_ world, lots of the machines are
already wasting most of its ram by running the desktop environment alone.

Diego Calleja (A user with 1 GB of RAM who usually gets his system
into swapping easily by using desktop apps and could benefit from
better page replacement policies)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
