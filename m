Message-Id: <200205151514.g4FFEmY13920@Port.imtp.ilyichevsk.odessa.ua>
Content-Type: text/plain;
  charset="us-ascii"
From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Subject: Re: [RFC][PATCH] iowait statistics
Date: Wed, 15 May 2002 18:17:22 -0200
References: <Pine.LNX.4.44L.0205151102030.9490-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.44L.0205151102030.9490-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15 May 2002 12:03, Rik van Riel wrote:
> > I was investigating why sometimes in top I see idle % like
> > 9384729374923.43%. It was caused by idle count in /proc/stat
> > going backward sometimes.
>
> Thanks for tracking down this bug.
>
> > It can be fixed for SMP:
> > * add spinlock
> > or
> > * add per_cpu_idle, account it too at timer/APIC int
> >   and get rid of idle % calculations for /proc/stat
> >
> > As a user, I vote for glitchless statistics even if they
> > consume extra i++ cycle every timer int on every CPU.
>
> Same for me. The last option is probably easiest to implement
> and cheapest at run time.

I think two patches for same kernel piece at the same time is
too many. Go ahead and code this if you want.

> The extra "cost" will approach zero
> once somebody takes the time to put the per-cpu stats on per
> cpu cache lines, which I'm sure somebody will do once we have
> enough per-cpu stats ;)

I thought about that too: per_cpu_xxx[cpu] -> per_cpu[cpu].xxx
type thing.
--
vda
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
