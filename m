Date: Tue, 10 Oct 2000 01:52:58 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010015258.C9520@athlon.random>
References: <20001010002520.B8709@athlon.random> <XFMail.20001010085923.peterw@mulga.surf.ap.tivoli.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <XFMail.20001010085923.peterw@mulga.surf.ap.tivoli.com>; from peterw@dascom.com.au on Tue, Oct 10, 2000 at 08:59:23AM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Waltenberg <peterw@dascom.com.au>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 10, 2000 at 08:59:23AM +1000, Peter Waltenberg wrote:
> never gets used, but the majority of kernels released ARE killable with memory
> pressure.

If those kernels are killable with memory pressure it's because of bugs
in the kernel not because of missing oom killer heuristic.

> That probably doesn't matter, the machine would be dead otherwise anyway. WITH

The current task may be almost as big as the one that we choosed to kill that
was hanging in a read from NFS and killing it (even if it wasn't selected by
the oom killer) would allow the machine to run again. The NFS server could
return alive only after several minutes instead.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
