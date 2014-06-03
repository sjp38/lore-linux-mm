Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id EBB376B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 15:26:05 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wo20so6520156obc.7
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 12:26:05 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id h1si276106obf.69.2014.06.03.12.26.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 12:26:05 -0700 (PDT)
Message-ID: <1401823560.4911.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 0/4] ipc/shm.c: increase the limits for SHMMAX, SHMALL
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 03 Jun 2014 12:26:00 -0700
In-Reply-To: <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	 <CAKgNAkjuU68hgyMOVGBVoBTOhhGdBytQh6H0ExiLoXfujKyP_w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 2014-05-02 at 15:16 +0200, Michael Kerrisk (man-pages) wrote:
> Hi Manfred,
> 
> On Mon, Apr 21, 2014 at 4:26 PM, Manfred Spraul
> <manfred@colorfullife.com> wrote:
> > Hi all,
> >
> > the increase of SHMMAX/SHMALL is now a 4 patch series.
> > I don't have ideas how to improve it further.
> 
> On the assumption that your patches are heading to mainline, could you
> send me a man-pages patch for the changes?

It seems we're still behind here and the 3.16 merge window is already
opened. Please consider this, and again feel free to add/modify as
necessary. I think adding a note as below is enough and was hesitant to
add a lot of details... Thanks.

8<--------------------------------------------------
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH] shmget.2: document new limits for shmmax/shmall

These limits have been recently enlarged and
modifying them is no longer really necessary.
Update the manpage.

Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
---
 man2/shmget.2 | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/man2/shmget.2 b/man2/shmget.2
index f781048..77764ea 100644
--- a/man2/shmget.2
+++ b/man2/shmget.2
@@ -299,6 +299,11 @@ with 8kB page size, it yields 2^20 (1048576).
 
 On Linux, this limit can be read and modified via
 .IR /proc/sys/kernel/shmall .
+As of Linux 3.16, the default value for this limit is increased to
+.B ULONG_MAX - 2^24
+pages, which is as large as it can be without helping userspace overflow
+the values. Modifying this limit is therefore discouraged. This is suitable
+for both 32 and 64-bit systems.
 .TP
 .B SHMMAX
 Maximum size in bytes for a shared memory segment.
@@ -306,6 +311,12 @@ Since Linux 2.2, the default value of this limit is 0x2000000 (32MB).
 
 On Linux, this limit can be read and modified via
 .IR /proc/sys/kernel/shmmax .
+As of Linux 3.16, the default value for this limit is increased from 32Mb
+to
+.B ULONG_MAX - 2^24
+bytes, which is as large as it can be without helping userspace overflow
+the values. Modifying this limit is therefore discouraged. This is suitable
+for both 32 and 64-bit systems.
 .TP
 .B SHMMIN
 Minimum size in bytes for a shared memory segment: implementation
-- 
1.8.1.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
