Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 90C5D6B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 19:41:43 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <cb50b439-1e5f-443e-9369-4f7c989d3565@default>
Date: Wed, 21 Mar 2012 16:30:03 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zcache preliminary benchmark results
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>, Akshay Karle <akshay.a.karle@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>

Last November, in an LKML thread I would rather forget*, James
Bottomley and others asked for some benchmarking to be done for
zcache (among other things).  For various reasons, that benchmarking
is just now getting underway and more will be done, but it might be
useful to publish some interesting preliminary results now.

Summary: On a kernel compile "make -jN" workload, with different
values of N to test varying memory pressure, zcache
shows no performance loss when memory pressure is low,
and up to 31% performance improvement when memory pressure
is moderate to high.  RAMster does even better.

(Note that RAM is intentionally constrained to 1GB to force
memory pressure for higher N in the workload.)

* thread summarized in LWN (http://lwn.net/Articles/465317/)

=3D=3D=3D=3D=3D=3D=3D=3D=3D

Benchmark results and description:

(all results in seconds so smaller is better)
N=3D=09nozcache=09zcache=09faster by=09RAMster=09faster by
4=09879=09=09877=09=090%=09=09887=09=09-1%
8=09858=09=09856=09=090%=09=09866=09=09-1%
12=09858=09=09856=09=090%=09=09875=09=09-2%
16=091009=09=09922=09=099%=09=09949=09=096%
20=091316=09=091154=09=0914%=09=091162=09=0913%
24=092164=09=091714=09=0926%=09=091788=09=0921%
28=093293=09=092500=09=0931%=09=092177=09=0951%
32=094286=09=094282=09=090%=09=093599=09=0919%
36=096516=09=096602=09=09-1%=09=095394=09=0922%
40=09DNC=09=0913755=09=09=09=098172=09=0968% (over zcache)

DNC=3Ddid not complete: stopped after 5 hours =3D 18000

Workload:
=09kernel compile "make -jN" with varying N
=09measurements in elapsed seconds
=09boot kernel: 3.2 + frontswap/ramster commits
=09Oracle Linux 6 distro with ext4
=09fresh reboot for each test run
=09all tests run as root in multi-user mode

Hardware:
=09Dell Optiplex 790 =3D ~$500 (two used for RAMster)
=09Intel Core i5-2400 @ 3.10 GHz, 4coreX2thread, 6M cache
=091GB RAM DDR3 1333Mhz (for RAMster, other server has 8GB)
=09One 7200rpm SATA 6.0Gb/s drive with 8MB cache
=0910GB swap partition

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
