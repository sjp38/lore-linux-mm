Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C2B4038EAC
	for <linux-mm@kvack.org>; Wed, 15 May 2002 11:03:51 -0300 (EST)
Date: Wed, 15 May 2002 11:03:38 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][PATCH] iowait statistics
In-Reply-To: <200205151214.g4FCEqY13273@Port.imtp.ilyichevsk.odessa.ua>
Message-ID: <Pine.LNX.4.44L.0205151102030.9490-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 May 2002, Denis Vlasenko wrote:

> I was investigating why sometimes in top I see idle % like
> 9384729374923.43%. It was caused by idle count in /proc/stat
> going backward sometimes.

Thanks for tracking down this bug.

> It can be fixed for SMP:
> * add spinlock
> or
> * add per_cpu_idle, account it too at timer/APIC int
>   and get rid of idle % calculations for /proc/stat
>
> As a user, I vote for glitchless statistics even if they
> consume extra i++ cycle every timer int on every CPU.

Same for me. The last option is probably easiest to implement
and cheapest at run time. The extra "cost" will approach zero
once somebody takes the time to put the per-cpu stats on per
cpu cache lines, which I'm sure somebody will do once we have
enough per-cpu stats ;)

cheers,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
