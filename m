Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0EDF06B00A3
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 13:40:32 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-class: urn:content-classes:message
Subject: Difference between CommitLimit and Comitted_AS?
Date: Wed, 1 Dec 2010 13:40:18 -0500
Message-ID: <B13AEDEE265EDB4182EA8B932E33033D13A904B7@SOSEXCHCL02.howost.strykercorp.com>
From: "Westerdale, John" <John.Westerdale@stryker.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

Am interested in differentiating the meaning of Commit* and Vmalloc*.

I had thought that the Committed_AS was the sum of memory allocations,
and Commit_Limit was the available memory to serve this from.

That said, I winced when I saw that Committed_AS was almost twice the
Commit__Limit.

Vmalloc looks inconsequential, but, the Commit* numbers must be there
for a reason.

Is it safe to continue running with such a perceived over-commit?

Is this evidence of a leak or garbage collection issues?

This system functions as an App/Web front end using  Tomcat servelet
engine, FWIW.

Thanks

John Westerdale


MemTotal:     16634464 kB
MemFree:      11077520 kB
Buffers:        420768 kB
Cached:        4379000 kB
SwapCached:          0 kB
Active:        4577960 kB
Inactive:       685344 kB
HighTotal:    15859440 kB
HighFree:     10987632 kB
LowTotal:       775024 kB
LowFree:         89888 kB
SwapTotal:     4194296 kB
SwapFree:      4194296 kB
Dirty:              12 kB
Writeback:           0 kB
AnonPages:      462748 kB
Mapped:          65420 kB
Slab:           260144 kB
PageTables:      21712 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:  12511528 kB
Committed_AS: 22423356 kB
VmallocTotal:   116728 kB
VmallocUsed:      6600 kB
VmallocChunk:   109612 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
Hugepagesize:     2048 kB=09

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
