Date: Tue, 14 Dec 1999 11:13:51 +0100
From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: 2.3 Pagedir allocation/free and update races
Message-ID: <19991214111351.U822@mff.cuni.cz>
References: <199912140946.BAA07601@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199912140946.BAA07601@google.engr.sgi.com>; from Kanoj Sarcar on Tue, Dec 14, 1999 at 01:46:00AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 1999 at 01:46:00AM -0800, Kanoj Sarcar wrote:
> This note describes races in the procedures that allocate and free
> user level page directories. Platform code maintainers, please
> read.

pgd_alloc/free are never invoked from interrupts and the kernel code is not
preemptive, so per-CPU caches are safe, aren't they?

Cheers,
    Jakub
___________________________________________________________________
Jakub Jelinek | jakub@redhat.com | http://sunsite.mff.cuni.cz/~jj
Linux version 2.3.26 on a sparc64 machine (1343.49 BogoMips)
___________________________________________________________________
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
