Message-ID: <3B622E12.404971A7@zip.com.au>
Date: Sat, 28 Jul 2001 13:14:26 +1000
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] MAX_READAHEAD gives doubled throuput
References: <200107280144.DAA25730@mailb.telia.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Roger Larsson wrote:
> 
> Hi all,
> 
> Got wondering why simultaneous streaming is so much slower than normal...
> 
> Are there any reasons nowadays why we should not attempt to read ahead more
> than 31 pages at once?
> 
> 31 pages equals 0.1 MB, it is read from the HD in 4 ms => very close to the
> average access times. Resulting in a maximum of half the possible speed.
> 
> With this patch copy and diff throughput are increased from 14 respective 11
> MB/s to 27 and 28 !!!
> 
> I enable the profiling as well... (one printk warning fixed)
> 

It doesn't make any difference here.

Dual 500MHz x86, 20 meg/sec IDE, 512 megs of RAM, kernel 2.4.7.
Diffing two kernel trees is 129 seconds without patch, 130 with.
Increasing MIN_READAHEAD to 31 as well saved eight seconds or so.

What kernel did you test with, and what are the specs for the
test machine?  Are your disks performing internal readahead?
If so, how much, and how large is the on-disk cache?



/dev/hdf:
 multcount    = 16 (on)
 I/O support  =  1 (32-bit)
 unmaskirq    =  1 (on)
 using_dma    =  1 (on)
 keepsettings =  0 (off)
 nowerr       =  0 (off)
 readonly     =  0 (off)
 readahead    =  8 (on)
 geometry     = 5606/255/63, sectors = 90069840, start = 0
mnm:/home/akpm> 0 hdparm -I /dev/hdf 

/dev/hdf:

 Model=BI-MTDAL3-7040 5                        , FwRev=XTO66AA0, SerialNo=        Y EMMYQG9424
 Config={ HardSect NotMFM HdSw>15uSec Fixed DTR>10Mbs }
 RawCHS=16383/16/63, TrkSize=0, SectSize=0, ECCbytes=40
 BuffType=DualPortCache, BuffSize=1916kB, MaxMultSect=16, MultSect=16
 CurCHS=65535/1/63, CurSects=4128705, LBA=yes, LBAsects=90069840
 IORDY=on/off, tPIO={min:240,w/IORDY:120}, tDMA={min:120,rec:120}
 PIO modes: pio0 pio1 pio2 pio3 pio4 
 DMA modes: mdma0 mdma1 mdma2 udma0 udma1 udma2 *udma3 udma4 udma5
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
