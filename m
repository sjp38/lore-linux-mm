Date: Thu, 28 Sep 2000 16:31:05 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000928163105.H17518@athlon.random>
References: <20000927155608.D27898@athlon.random> <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Sep 28, 2000 at 07:08:51AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 28, 2000 at 07:08:51AM -0300, Rik van Riel wrote:
> taking care of this itself. But this is not something the OS
> should prescribe to the application.

Agreed.

> (unless the SHM users tell you that this is the normal way
> they use SHM ... but as Christoph just told us, it isn't)

shm is not used as I/O cache from 90% of the apps out there because normal apps
uses the OS cache functionality (90% of those apps doesn't use rawio to share a
black box that looks like a scsi disk via SCSI bus connected to other hosts as
well).

I for sure agree shm swapin/swapout is very important. (we moved shm
swapout/swapin to swap cache with readaround for that reason)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
