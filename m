Date: Wed, 18 Apr 2001 23:32:25 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...) 
In-Reply-To: <Pine.LNX.4.21.0104171648010.14442-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.30.0104182315010.20939-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Apr 2001, Rik van Riel wrote:
> On Mon, 16 Apr 2001, Szabolcs Szakacsits wrote:
> > Please don't. Or at least make it optional and not the default or user
> > controllable. Trashing is good.
> This sounds like you have no idea what thrashing is.

Sorry, your comment isn't convincing enough ;) Why do you think
"arbitrarily" (decided exclusively by the kernel itself) suspending
processes (that can be done in user space anyway) would help?

Even if you block new process creation and memory allocations (that's
also not nice since it can be done by resource limits) why you think
situation will ever get better i.e. processes release memory?

How you want to avoid "deadlocks" when running processes have
dependencies on suspended processes?

What control you plan for sysadmins who *want* to get feedback about bad
setups as soon as possible?

How you plan to explain on comp.os.linux.development.applications
that your *perfect* programs can't only be SIGKILL'd by kernel at any
time but also suspended for indefinite time from now?

Sure it would help in cases and in others it would utterly fail. Just
like the thrasing case. So as such I see it an unnecessary bloat adding
complexity and no real functionality.

        Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
