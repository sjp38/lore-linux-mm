Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7FECC5F0001
	for <linux-mm@kvack.org>; Sun,  1 Feb 2009 06:19:12 -0500 (EST)
Received: by fk-out-0910.google.com with SMTP id z22so1056246fkz.6
        for <linux-mm@kvack.org>; Sun, 01 Feb 2009 03:19:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090129141929.GP24391@elte.hu>
References: <8c5a844a0901220851g1c21169al4452825564487b9a@mail.gmail.com>
	 <Pine.LNX.4.64.0901221658550.14302@blonde.anvils>
	 <8c5a844a0901221500m7af8ff45v169b6523ad9d7ad3@mail.gmail.com>
	 <20090122231358.GA27033@elte.hu>
	 <8c5a844a0901230310h7aa1ec83h60817de2b36212d8@mail.gmail.com>
	 <8c5a844a0901281331w4cea7ab2y305d5a1af96e313e@mail.gmail.com>
	 <20090129141929.GP24391@elte.hu>
Date: Sun, 1 Feb 2009 13:19:10 +0200
Message-ID: <8c5a844a0902010319t20b853d0t6c156ecc84543f30@mail.gmail.com>
Subject: Re: [PATCH 2.6.28 1/2] memory: improve find_vma
From: Daniel Lowengrub <lowdanie@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 1/29/09, Ingo Molnar <mingo@elte.hu> wrote:
> Here's an mmap performance tester:
>
>    http://redhat.com/~mingo/misc/mmap-perf.c
>
> maybe that shows a systematic effect. If you've got a Core2 based
> test-system then you could try perfstat as well, for much more precise
> instruction counts. (can give you more info about how to do that if you
> have such a test-system.)
>
>        Ingo
>
I compiled mmap-perf.c an ran it with ./mmap-perf 1 (not as root, does
that matter?).  As obvious from the code, the output that I got was
the final state of the /proc/[self]/maps file.  How does this
information tell me about performance?  Anyhow, here're the first 10
lines of the [heap] part of the output using the standard kernel:
0965b000-0967c000 rw-p 0965b000 00:00 0          [heap]
86007000-86009000 rw-p 86007000 00:00 0
86009000-8600a000 ---p 86009000 00:00 0
86018000-8601b000 rw-p 86018000 00:00 0
8601c000-86023000 -w-p 8601c000 00:00 0
86023000-86026000 rw-p 86023000 00:00 0
86026000-86029000 r--p 86026000 00:00 0
8603e000-86040000 rw-p 8603e000 00:00 0
86048000-8604c000 r--p 86048000 00:00 0
8604f000-86054000 ---p 8604f000 00:00 0
and here're the first 10 lines of the output with the patch applied:
09596000-095b7000 rw-p 09596000 00:00 0          [heap]
860ab000-860ad000 rw-p 860ab000 00:00 0
860ad000-860ae000 ---p 860ad000 00:00 0
860bc000-860bf000 rw-p 860bc000 00:00 0
860c0000-860c7000 -w-p 860c0000 00:00 0
860c7000-860ca000 rw-p 860c7000 00:00 0
860ca000-860cd000 r--p 860ca000 00:00 0
860e2000-860e4000 rw-p 860e2000 00:00 0
860ec000-860f0000 r--p 860ec000 00:00 0
860f3000-860f8000 ---p 860f3000 00:00 0
I can't see how this can show performance differences but I'm not sure
what other
part of the output is relevant.  Should I run it with some other options?
Thanks,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
