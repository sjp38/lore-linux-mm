Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 632256B0108
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 14:34:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <7297ae3b-f3e1-480b-838f-69b0e09a733d@default>
Date: Mon, 16 Apr 2012 11:34:12 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Followup: [PATCH -mm] make swapin readahead skip over holes
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Hi Rik --

I saw this patch in 3.4-rc1 (because it caused a minor merge
conflict with frontswap) and wondered about its impact.
Since I had a server still set up from running benchmarks
before LSFMM, I ran my kernel compile -jN workload (with
N varying from 4 to 40) on 1GB of RAM, on 3.4-rc2 both with
and without this patch.

For values of N=3D24 and N=3D28, your patch made the workload
run 4-9% percent faster.  For N=3D16 and N=3D20, it was 5-10%
slower.  And for N=3D36 and N=3D40, it was 30%-40% slower!

Is this expected?  Since the swap "disk" is a partition
on the one active drive, maybe the advantage is lost due
to contention?

Thanks,
Dan

commit removed 67f96aa252e606cdf6c3cf1032952ec207ec0cf0

Workload:
=09kernel compile "make -jN" with varying N
=09measurements in elapsed seconds
=09boot kernel: 3.4-rc2
=09Oracle Linux 6 distro with ext4
=09fresh reboot for each test run
=09all tests run as root in multi-user mode

Hardware:
=09Dell Optiplex 790 =3D ~$500
=09Intel Core i5-2400 @ 3.10 GHz, 4coreX2thread, 6M cache
=091GB RAM DDR3 1333Mhz (to force swapping)
=09One 7200rpm SATA 6.0Gb/s drive with 8MB cache
=0910GB swap partition

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
