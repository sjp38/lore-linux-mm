Date: Sat, 5 Jul 2003 12:14:16 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.5.74-mm1
Message-Id: <20030705121416.62afd279.akpm@osdl.org>
In-Reply-To: <200307051728.12891.phillips@arcor.de>
References: <20030703023714.55d13934.akpm@osdl.org>
	<200307050216.27850.phillips@arcor.de>
	<200307051728.12891.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:
>
> The situation re scheduling in 2.5 feels much as 
> the vm situation did in 2.3

I've been trying to avoid thinking about that comparison.

I don't think it's really, really bad at present.  Just "should be a bit
better".

> Kgdb is no help in 
> diagnosing, as the kgdb stub also goes comatose, or at least the serial link 
> does.  No lockups have occurred so far when I was not interacting with the 
> system via the keyboard or mouse.  Suggestions?

Enable IO APIC, Local APIC, nmi watchdog.  Use serial console, see if you
can get a sysrq trace out of it.  That's `^A F T' in minicom.

I mean, it _has_ to be either stuck with interrupts on, or stuck with them off.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
