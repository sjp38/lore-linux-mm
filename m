Received: from savion.cc.huji.ac.il (savion.cc.huji.ac.il [132.64.16.16])
	by mail3.cc.huji.ac.il (Postfix) with ESMTP id 406F068113
	for <linux-mm@kvack.org>; Mon, 29 Sep 2003 16:11:13 +0300 (IDT)
Message-ID: <32F7E536759ED611BBA9001083CFB165C07334@savion.cc.huji.ac.il>
From: Liviu Voicu <liviuv@savion.cc.huji.ac.il>
Subject: Zombies
Date: Mon, 29 Sep 2003 16:14:54 +0300
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>Works on but I have zombie processes:

liviu@starshooter liviu $ ps axf
  PID TTY      STAT   TIME COMMAND
    1 ?        S      0:04 init [3]
    2 ?        SWN    0:00 [ksoftirqd/0]
    3 ?        SW<    0:00 [events/0]
 3158 ?        Z<     0:00  \_ [events/0] <defunct>
 3162 ?        Z<     0:00  \_ [events/0] <defunct>
 3331 ?        Z<     0:00  \_ [events/0] <defunct>
 3333 ?        Z<     0:00  \_ [events/0] <defunct>
 3512 ?        Z<     0:00  \_ [events/0] <defunct>

>>>Also top says(see the NICE column, lot of negative values, is it
normal?):

top - 16:09:48 up 13 min,  2 users,  load average: 0.32, 0.43, 0.30
Tasks:  67 total,   1 running,  61 sleeping,   0 stopped,   5 zombie
Cpu(s):  10.7% user,   0.9% system,   0.0% nice,  88.3% idle,   0.0%
IO-wait
Mem:    256432k total,   218412k used,    38020k free,    11760k buffers
Swap:   313228k total,        0k used,   313228k free,   100356k cached
 

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  Command
 3451 root      15   0 30280  19m  11m S  4.6  7.9   0:49.88 X
 3511 liviu     16   0 66312  39m  30m S  4.3 15.9   1:43.52
thunderbird-bin
 3558 liviu     15   0 18268 9588  14m S  1.5  3.7   0:02.36
gnome-terminal
 3571 liviu     17   0  1884  988 1748 R  0.9  0.4   0:00.10 top
 3330 root      15   0  1424  600 1336 S  0.3  0.2   0:00.42 pptp
 3523 liviu     16   0 66312  39m  30m S  0.3 15.9   0:00.07
thunderbird-bin
    1 root      16   0  1340  492 1304 S  0.0  0.2   0:04.22 init
    2 root      34  19     0    0    0 S  0.0  0.0   0:00.00 ksoftirqd/0
    3 root       5 -10     0    0    0 S  0.0  0.0   0:00.01 events/0
    4 root       5 -10     0    0    0 S  0.0  0.0   0:00.00 kblockd/0
    5 root      25   0     0    0    0 S  0.0  0.0   0:00.00 pdflush
    6 root      15   0     0    0    0 S  0.0  0.0   0:00.11 pdflush
    7 root      25   0     0    0    0 S  0.0  0.0   0:00.00 kswapd0
    8 root      10 -10     0    0    0 S  0.0  0.0   0:00.00 aio/0
    9 root      10 -10     0    0    0 S  0.0  0.0   0:00.00 aio_fput/0
   10 root      22   0     0    0    0 S  0.0  0.0   0:00.00 kseriod
   11 root      10 -10     0    0    0 S  0.0  0.0   0:00.00 reiserfs/0
  162 root      15   0  1716  904 1448 S  0.0  0.4   0:00.09 devfsd
 3012 root      16   0  1672  580 1356 S  0.0  0.2   0:00.01 metalog
 3013 root      16   0  1408  496 1356 S  0.0  0.2   0:00.00 metalog
 3155 root      16   0  1416  592 1336 S  0.0  0.2   0:00.00 pptp
 3158 root       6 -10     0    0    0 Z  0.0  0.0   0:00.00 events/0
<defunct>
 3161 root      16   0  1992  944 1708 S  0.0  0.4   0:00.03 pppd
 3162 root       5 -10     0    0    0 Z  0.0  0.0   0:00.00 events/0
<defunct>
 3272 root      16   0  1612  632 1420 S  0.0  0.2   0:00.00 cron
 3314 root      19   0  2036  848 1752 S  0.0  0.3   0:00.09 xinetd
 3327 root      18   0  2252 1216 1876 S  0.0  0.5   0:00.18 login
 3328 root      16   0  1376  592 1328 S  0.0  0.2   0:00.00 agetty
 3329 root      16   0  1376  592 1328 S  0.0  0.2   0:00.00 agetty
 3331 root       6 -10     0    0    0 Z  0.0  0.0   0:00.00 events/0
<defunct>
 3333 root       6 -10     0    0    0 Z  0.0  0.0   0:00.00 events/0
<defunct>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
