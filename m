Date: Sat, 24 Mar 2001 17:56:27 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Reduce Linux memory requirements for an Embedded PC
Message-ID: <20010324175627.F26121@nightmaster.csn.tu-chemnitz.de>
References: <20010324133926.A1584@fred.local> <Pine.LNX.4.21.0103241319480.1863-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0103241319480.1863-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Sat, Mar 24, 2001 at 01:21:29PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andi Kleen <ak@muc.de>, Petr Dusil <pdusil@razdva.cz>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 24, 2001 at 01:21:29PM -0300, Rik van Riel wrote:
> I'm willing to work on a CONFIG_TINY option for 2.5 which
> does things like this (but I'll have to finish some VM
> things first ;)).

Why not 2.4? It is only a configuration thing, right? People are
using Linux more and more for embedded stuff. So waiting 2 years
more is not an option.

I'm willing to help, if we collect some ideas on WHAT to do
first.

I had problems even on 64MB with no swap attached, so this is a
serious problem (look at comment on OOM killer does not trigger).

Esp. in the network layer we need to reduce memory usage, since
this triggered it for me on this oversized box.

Also a set of configs (may be sysctl stuff) to adjust trade-off
decisions on throughput vs. latency or memory vs. speed and the
like.

Autotuning is nice, but has always the chance to fail for corner
cases. Taking these into account to generates too much code
bloat. So making the required tunables available (as already
happend with threads-max, file-max and the like) is supporting
the idea of 'providing features, not policy'.

Regards

Ingo Oeser
-- 
10.+11.03.2001 - 3. Chemnitzer LinuxTag <http://www.tu-chemnitz.de/linux/tag>
         <<<<<<<<<<<<     been there and had much fun   >>>>>>>>>>>>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
