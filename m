Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0E36B02EE
	for <linux-mm@kvack.org>; Wed,  3 May 2017 07:32:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p18so17954216wrb.22
        for <linux-mm@kvack.org>; Wed, 03 May 2017 04:32:42 -0700 (PDT)
Received: from rrzmta1.uni-regensburg.de (rrzmta1.uni-regensburg.de. [194.94.155.51])
        by mx.google.com with ESMTPS id l37si20952827wrl.237.2017.05.03.04.32.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 May 2017 04:32:41 -0700 (PDT)
Received: from rrzmta1.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 54AD55B2E0
	for <linux-mm@kvack.org>; Wed,  3 May 2017 13:32:40 +0200 (CEST)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta1.uni-regensburg.de (Postfix) with ESMTP id 3409E5B2CD
	for <linux-mm@kvack.org>; Wed,  3 May 2017 13:32:40 +0200 (CEST)
Message-Id: <5909BFD6020000A100025CBF@gwsmtp1.uni-regensburg.de>
Date: Wed, 03 May 2017 13:32:38 +0200
From: "Ulrich Windl" <Ulrich.Windl@rz.uni-regensburg.de>
Subject: Improve documentation request for /proc/meminfo (proc.txt)
References: <5909BFD6020000A100025CBF@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi!

Reading /usr/src/linux/Documentation/filesystems/proc.txt leaves some =
questions open. For example some values are break-downs of others. I'd =
like to see documentation on how these relate. For example (3.0.101):

MemTotal:       132156332 kB
MemFree:        22448480 kB
Buffers:         1484072 kB
Cached:         81252832 kB
SwapCached:            0 kB
Active:         24216920 kB
Inactive:       65789500 kB
Active(anon):   20268724 kB
Inactive(anon):  4617808 kB
Active(file):    3948196 kB
Inactive(file): 61171692 kB
Unevictable:       48840 kB
Mlocked:           30444 kB
SwapTotal:      20964788 kB
SwapFree:       20964788 kB
Dirty:               496 kB
Writeback:             0 kB
AnonPages:       7317972 kB
Mapped:         15927688 kB
Shmem:          17602008 kB
Slab:            1162160 kB
SReclaimable:     907496 kB
SUnreclaim:       254664 kB
KernelStack:        8864 kB
PageTables:      1361780 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    79158152 kB
Committed_AS:   66056192 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      305164 kB
VmallocChunk:   34292267888 kB
HardwareCorrupted:     0 kB
AnonHugePages:   4997120 kB
HugePages_Total:    7700
HugePages_Free:       62
HugePages_Rsvd:       44
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      301296 kB
DirectMap2M:    19611648 kB
DirectMap1G:    114294784 kB

Which numbers sum up to MemTotal? It seems Active(anon) + Active(file) =
=3D=3D Active (and similar for inactive).
What is the relation between Unevictable and Mlocked? Is "Unevictable >=3D =
Mlocked" all the time?
It would give some insight how things work if you document the relations =
between some of these numbers.

(I'm hunting for a condition for very bad disk response times, suspecting =
some memory pressure. I suspect too many dirty pages for some reason...)

Regards,
Ulrich





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
