Date: Sun, 13 Oct 2002 18:04:51 +0200
From: Henrik =?iso-8859-1?Q?St=F8rner?= <henrik@hswn.dk>
Subject: 2.5.42-mm2 hangs system
Message-ID: <20021013160451.GA25494@hswn.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I gave 2.5.42-mm2 a test run yesterday, and it hung the box solid
while doing a kernel compile. The compile stopped dead in the middle
of a file, and there was no response when trying to access another
console (no X running). Alt-sysrq worked, so it wasn't completely dead
- sync/umount/reboot worked.

Nothing in the logs - no oops or other kernel messages.

Rebooted and repeated the experiment with the same result,
so it appears to be reproducible.

Stock 2.5.42 has worked OK for a day now, including kernel
compiles - the system has performed flawlessly for a 
couple of years as my normal workstation.

PII processor, 384 MB RAM, SCSI disk (ncr53c8xx driver),
Intel eepro/100 network adapter. Kernel config at
http://www.hswn.dk/config-2.5.42-mm2

-- 
Henrik Storner <henrik@hswn.dk> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
