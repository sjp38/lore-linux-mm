Date: Fri, 6 Oct 2000 16:19:55 -0400 (EDT)
From: Byron Stanoszek <gandalf@winds.org>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.21.0010061555150.13585-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0010061611540.2191-100000@winds.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Oct 2000, Rik van Riel wrote:

> 3. add the out of memory killer, which has been tuned with
>    -test9 to be ran at exactly the right moment; process
>    selection: "principle of least surprise"  <== OOM handling

In the OOM killer, shouldn't there be a check for PID 1 just to enforce that
INIT will not be the victim? Sure its total_vm might be small, but if there was
a memory leak in the kernel somewhere, it might eventually become the target.
I suppose, if it ever were to become the victim, your system wouldn't be too
usable anyway...

Can you give me your rationale for selecting 'nice' processes as being badder?
Do you think it would be a good idea to scale the amount of badness according
to how nice the process is (a nice value of 20 could get the full *2, otherwise
a smaller multiplier)?

How about using the current process priority level instead of nicety. If a
process was deprioritized (or auto-niced) because it was starting to eat up CPU
time, AND its memory is abnormally high, then should that be our #1 victim? We
also don't want to kill things like benchmarks either, but hopefully they
wouldn't start eating up more than the available system memory.

Just some thoughts.

 -Byron

-- 
Byron Stanoszek                         Ph: (330) 644-3059
Systems Programmer                      Fax: (330) 644-8110
Commercial Timesharing Inc.             Email: bstanoszek@comtime.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
