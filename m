Date: Thu, 28 Sep 2000 16:54:27 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000928165427.K17518@athlon.random>
References: <Pine.LNX.4.21.0009280702460.1814-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0009281329270.5655-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009281329270.5655-100000@elte.hu>; from mingo@elte.hu on Thu, Sep 28, 2000 at 01:31:40PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 28, 2000 at 01:31:40PM +0200, Ingo Molnar wrote:
> if the shm contains raw I/O data, then thats flawed application design -
> an mmap()-ed file should be used instead. Shm is equivalent to shared

The DBMS uses shared SCSI disks across multiple hosts on the same SCSI bus
and synchronize the distributed cache via TCP. Tell me how to do that
with the OS cache and mmap.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
