Message-ID: <39639FEA.4CBCB4FC@norran.net>
Date: Wed, 05 Jul 2000 22:51:54 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: 2.4.0-test3-pre2: corruption in mm?
References: <3961A761.974CED49@norran.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, Jens Axboe <axboe@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

After a cold reboot I got it again, this time I made a note:

- - -
Checking file systems...
Parallelizing fsck 1.17 26-oct-1999

 c4 clean
 c2 clean
 a4 clean
 b4 The filesystem size (according to the superblock)
is 1281183 blocks.
The physical size of the device is 1280146 blocks.
Eigher the superblock or the partition table is likely
to be corrupt!

/dev/dhb4: UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY
...


I got this yesterday after a (cold)reboot another (warm)reboot
and e2fsck it (warm)booted, several times, without problems.
[both 2.2.14 and 2.4.0-test3-2 with latency improvements has
 been running]

First cold boot, Linux 2.2.14, today and I get it again...
Direct reboot into 2.2.14, resulted in fsck 

(I did try 2.4.0-test2 but I believe that this drive was
 installed after that)

Disk part of boot follows.
Note: ST320423A is a 20,4MB disk...

/RogerL

<4>PIIX3: IDE controller on PCI bus 00 dev 39
<4>PIIX3: not 100% native mode: will probe irqs later
<4>    ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:pio, hdb:pio
<4>    ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:pio, hdd:pio
<4>hda: WDC AC33200L, ATA DISK drive
<4>hdb: ST320423A, ATA DISK drive
<4>hdc: WDC AC22100H, ATA DISK drive
<4>ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
<4>ide1 at 0x170-0x177,0x376 on irq 15
<6>hda: WDC AC33200L, 3098MB w/256kB Cache, CHS=787/128/63, (U)DMA
<6>hdb: ST320423A, 19536MB w/512kB Cache, CHS=2490/255/63, (U)DMA
<4>hdc: Disabling (U)DMA for WDC AC22100H
<4>hdc: DMA disabled
<6>hdc: WDC AC22100H, 2014MB w/128kB Cache, CHS=4092/16/63

Roger Larsson wrote:
> 
> Hi,
> 
> When I booted up today mount complained that one of my disks
> was not ok. (/usr)
> 
> e2fsck complained that it could not run automatically.
> (It was properly shut down)
> 
> Rescue reboot and manual e2fsck made it ok again.
> 
> Sorry about the undetailed report...
> 
> /RogerL
> 
> --
> Home page:
>   http://www.norran.net/nra02596/
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
