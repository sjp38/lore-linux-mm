Message-ID: <20010322200408.A5404@win.tue.nl>
Date: Thu, 22 Mar 2001 20:04:08 +0100
From: Guest section DW <dwguest@win.tue.nl>
Subject: Re: [PATCH] Prevent OOM from killing init
References: <20010322124727.A5115@win.tue.nl> <Pine.LNX.4.21.0103221200410.21415-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0103221200410.21415-100000@imladris.rielhome.conectiva>; from Rik van Riel on Thu, Mar 22, 2001 at 12:01:43PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 22, 2001 at 12:01:43PM -0300, Rik van Riel wrote:

> > Last month I had a computer algebra process running for a week.
> > Killed. But this computation was the only task this machine had.
> > Its sole reason of existence.
> > Too bad - zero information out of a week's computation.
> > 
> > Clearly, Linux cannot be reliable if any process can be killed
> > at any moment. I am not happy at all with my recent experiences.
> 
> Note that the OOM killer in 2.4 won't kick in until your machine
> is out of both memory and swap, see mm/oom_kill.c::out_of_memory().

Nevertheless, this process does malloc and malloc returns the requested
memory. If a malloc fails the computer algebra process has the choice
between various alternatives. Present a prompt, so that the user can
examine variables and intermediate results, or request a dump to disk
of the status of the computation. Or choose an alternative algorithm,
at some other point of the space-time tradeoff curve.
But no error return from malloc - just "Killed". Ach.

Andries
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
