Date: Thu, 22 Jun 2000 22:00:49 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] RSS guarantees and limits
Message-ID: <20000622220049.G28360@pcep-jamie.cern.ch>
References: <20000622214819.C28360@pcep-jamie.cern.ch> <Pine.LNX.4.21.0006221651230.1170-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0006221651230.1170-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Jun 22, 2000 at 04:52:29PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: frankeh@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> > Be careful with refault rate.  If a process is unable to
> > progress because of memory pressure, it will have a low refault
> > rate even though it's _trying_ to fault in lots of pages at high
> > speed.
> 
> We probably want to use fault rate and memory size too in
> order to promote fairness.

The number of global memory events between the process getting one page
and requesting the next may indicate of how much page activity the
process is trying to do.  (Relative to other memory users).

> All of this may sound complicated, but as long as we make
> sure that the feedback cycles are short (and negative ;))
> it should all work out...

Keeping them negative is tricky :-)

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
