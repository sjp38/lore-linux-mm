Subject: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 05 Sep 2002 11:23:59 -0600
Message-Id: <1031246639.2799.68.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I booted 2.5.33-mm3 and ran dbench with increasing
numbers of clients: 1,2,3,4,6,8,10,12,16,etc. while
running vmstat -n 1 600 from another terminal.

After about 3 minutes, the output from vmstat stopped,
and the dbench 16 output stopped.  The machine would
respond to pings, but not to anything else. I had to 
hard-reset the box. Nothing interesting was saved in 
/var/log/messages. I have the output from vmstat if needed.

The test box is dual p3, 1GB, scsi, ext3 fs.
Kernels are SMP,_HIGHMEM4G, no PREEMPT, no HIGHPTE. 

Earlier this morning, I ran 2.5.33 and the dbench test and got many
page allocation failure messages before I terminated the test.

Steven

Sep  5 07:20:01 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:28:32 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:37:46 spc5 last message repeated 2 times
Sep  5 07:37:47 spc5 last message repeated 9 times
Sep  5 07:37:47 spc5 kernel: klogd: page allocation failure. order:0, mode:0x50
Sep  5 07:37:56 spc5 last message repeated 23 times
Sep  5 07:37:56 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:38:00 spc5 last message repeated 17 times
Sep  5 07:38:00 spc5 kernel: dbench: page allocation failure. order:0, mode:0x20
Sep  5 07:38:00 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:38:06 spc5 last message repeated 22 times
Sep  5 07:41:01 spc5 kernel: kjournald: page allocation failure. order:0, mode:0x0
Sep  5 07:43:23 spc5 kernel: kjournald: page allocation failure. order:0, mode:0x0
Sep  5 07:44:36 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:44:44 spc5 last message repeated 37 times
Sep  5 07:44:44 spc5 kernel: dbench: page allocation failure. order:0, mode:0x0
Sep  5 07:44:44 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:44:54 spc5 last message repeated 48 times
Sep  5 07:45:44 spc5 kernel: pdflush: page allocation failure. order:0, mode:0x0
Sep  5 07:49:13 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:50:03 spc5 last message repeated 2 times
Sep  5 07:50:12 spc5 last message repeated 39 times
Sep  5 07:50:12 spc5 kernel: kswapd: page allocation failure. order:0, mode:0x50
Sep  5 07:50:49 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:50:55 spc5 last message repeated 62 times
Sep  5 07:51:45 spc5 kernel: kjournald: page allocation failure. order:0, mode:0x0
Sep  5 07:54:40 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:54:48 spc5 last message repeated 35 times
Sep  5 07:54:48 spc5 kernel: age allocation failure. order:0, mode:0x50
Sep  5 07:54:48 spc5 kernel: dbench: page allocation failure. order:0, mode:0x50
Sep  5 07:55:18 spc5 last message repeated 627 times




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
