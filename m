Date: Fri, 6 Oct 2000 23:27:18 +0200
From: David Weinehall <tao@acc.umu.se>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001006232718.E22187@khan.acc.umu.se>
References: <Pine.LNX.4.21.0010061555150.13585-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0010061611540.2191-100000@winds.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010061611540.2191-100000@winds.org>; from gandalf@winds.org on Fri, Oct 06, 2000 at 04:19:55PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Byron Stanoszek <gandalf@winds.org>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 06, 2000 at 04:19:55PM -0400, Byron Stanoszek wrote:
> On Fri, 6 Oct 2000, Rik van Riel wrote:
> 
> > 3. add the out of memory killer, which has been tuned with
> >    -test9 to be ran at exactly the right moment; process
> >    selection: "principle of least surprise"  <== OOM handling

I've tested v2.4.0test9+RielVMpatch now, together with the
memory_static program. It works terrific. No innocent process got
killed, just the offending one. And not until the memory was completely
depleted.

> In the OOM killer, shouldn't there be a check for PID 1 just to enforce that
> INIT will not be the victim? Sure its total_vm might be small, but if there
> was a memory leak in the kernel somewhere, it might eventually become the
> target.

If INIT has a memory-leak, it deserves to die. We have bigger problems
then anyway... And certainly, if INIT gets killed, we quickly notice
that something is wrong.

> I suppose, if it ever were to become the victim, your system wouldn't
> be too usable anyway...

Correct.

> Can you give me your rationale for selecting 'nice' processes as being
> badder?  Do you think it would be a good idea to scale the amount of
> badness according to how nice the process is (a nice value of 20 could
> get the full *2, otherwise a smaller multiplier)?
> 
> How about using the current process priority level instead of nicety.
> If a process was deprioritized (or auto-niced) because it was starting
> to eat up CPU time, AND its memory is abnormally high, then should
> that be our #1 victim? We also don't want to kill things like
> benchmarks either, but hopefully they wouldn't start eating up more
> than the available system memory.

I wouldn't care a least bit if a benchmark I'm running gets killed if
the memory runs out, but if my dnetc client which has low priority and
neatly works in the background without disturbing anything suddenly
gets killed when another program starts eating memory, I'd be dang
angry...


Standing ovations for Rik van Riel. You've managed to get the VM in
good shape, at least for my machine... Now I'll test it for some machines
with less and more memory (4MB and 64MB ram, with 16MB swap and 
0/256/512/1024/2048 MB swap respectively.)


/David
  _                                                                 _
 // David Weinehall <tao@acc.umu.se> /> Northern lights wander      \\
//  Project MCA Linux hacker        //  Dance across the winter sky //
\>  http://www.acc.umu.se/~tao/    </   Full colour fire           </
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
