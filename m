Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5D5236B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 19:26:20 -0400 (EDT)
Received: by gyg4 with SMTP id 4so2890919gyg.14
        for <linux-mm@kvack.org>; Mon, 19 Apr 2010 16:28:08 -0700 (PDT)
MIME-Version: 1.0
From: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>
Date: Mon, 19 Apr 2010 20:27:43 -0300
Message-ID: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com>
Subject: Suspicious compilation warning
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I get this warning while compiling for ARM/SA1100:

mm/sparse.c: In function '__section_nr':
mm/sparse.c:135: warning: 'root' is used uninitialized in this function

With a small patch in fs/proc/meminfo.c, I find that NR_SECTION_ROOTS
is zero, which certainly explains the warning.

# cat /proc/meminfo
NR_SECTION_ROOTS=0
NR_MEM_SECTIONS=32
SECTIONS_PER_ROOT=512
SECTIONS_SHIFT=5
MAX_PHYSMEM_BITS=32
SECTION_SIZE_BITS=27
MemTotal:          28848 kB
MemFree:           15516 kB
Buffers:             112 kB
Cached:             2312 kB
SwapCached:            0 kB
Active:              984 kB
Inactive:           1628 kB
Active(anon):        188 kB
Inactive(anon):        0 kB
Active(file):        796 kB
Inactive(file):     1628 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                24 kB
Writeback:             0 kB
AnonPages:           208 kB
Mapped:              292 kB
Shmem:                 0 kB
Slab:               1472 kB
SReclaimable:        744 kB
SUnreclaim:          728 kB
KernelStack:         200 kB
PageTables:           32 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:       14424 kB
Committed_AS:        772 kB
VmallocTotal:     614400 kB
VmallocUsed:       33316 kB
VmallocChunk:     573436 kB

Regards,
Marcelo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
