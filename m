Date: Sat, 25 Sep 1999 16:31:52 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: oom - out of memory
In-Reply-To: <14314.28197.161697.652050@verona.neomorphic.com>
Message-ID: <Pine.LNX.4.10.9909251628210.1083-100000@laser.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Kulp <dkulp@neomorphic.com>
Cc: Kestutis Kupciunas <kesha@soften.ktu.lt>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Sep 1999, David Kulp wrote:

>I have just the same problem with the same kernels: system hangs when
>one process requires more than total RAM.  I can't kill processes or
>otherwise get any response.  No syslog messages.  I don't know where
>to start to try to track down this problem -- but I thought monitoring
>this list would be a start.  Ironically -- considering the recent
>'ammo' thread, I had no trouble with this in FreeBSD.    )-:

I fixed a potential oom deadlock and some omm related bug in the VM at
2.2.10 time. Unfortunately it's not been merged in the stock kernel yet
(it also breaks all architectures and I fixed only i386 and Alpha as I
don't have access to other hardware).

Please apply this my fix and give us back any positive/negative feedback.

	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/2.2.12/oom-2.2.12-I

Thanks!

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
