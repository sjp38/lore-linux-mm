Message-ID: <170EBA504C3AD511A3FE00508BB89A92021C912E@exnanycmbx4.ipc.com>
From: "Downing, Thomas" <Thomas.Downing@ipc.com>
Subject: RE: 2.5.70-mm1
Date: Wed, 28 May 2003 09:26:32 -0400
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----Original Message-----
From: Andrew Morton [mailto:akpm@digeo.com]
>
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.70-mm1.gz
>
>   Will appear soon at
>
>
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-
mm1/
>
> . A number of fixes against the ext3 work which Alex and I have been
doing.
>   This code is stable now.  I'm using it on my main SMP desktop machine.
>
>   These are major changes to a major filesystem.  I would ask that
>   interested parties now subject these patches to stresstesting and to
>   performance testing.  The performance gains on SMP will be significant.
[snip]

Running this version for 2 days now on heavily used build machine.
No problems to report.  Here are some numbers for kernel build.
Machine is SMP, 2 Xeon P4, Intel chipset, single IDE HD, with
hyperthreading enabled.

2.5.67-bk4 (i think bk4):

       make -j1   make -j4
       --------   --------
real   5m03.889   2m37.253
user   4m27.550   4m41.037
sys    0m27.727   0m29.651

2.5.70-mm1:

       make -j1   make -j4
       --------   --------
real   4m52.212   2m41.565
user   4m27.447   4m40.462
sys    0m29.079   0m31.184

This test does not show any significant difference.  On the other hand,
even with -j4 the disk activity is light.  If you have a better test
that you would like me to run, point me to it, and I'll do it.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
