Subject: Re: 2.5.70-mm6
References: <20030607151440.6982d8c6.akpm@digeo.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 08 Jun 2003 02:37:07 +0200
In-Reply-To: <20030607151440.6982d8c6.akpm@digeo.com>
Message-ID: <873cilz9os.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> writes:
>
> [SNIP]
>

It builds nicely here and runs nicely so far, but my USB-drive still
blows up after a few gigs and I have this one when plugging it in:

Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
spurious 8259A interrupt: IRQ7.
SCSI device sda: 490232832 512-byte hdwr sectors (250999 MB)
sda: cache data unavailable
sda: assuming drive cache: write through
 /dev/scsi/host0/bus0/target0/lun0: p1
devfs_mk_dir(scsi/host0/bus0/target0/lun0): could not append to dir: ea549820 "target0"
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
kjournald starting.  Commit interval 5 seconds
EXT3 FS 2.4-0.9.16, 02 Dec 2001 on sda1, internal journal
EXT3-fs: recovery complete.
EXT3-fs: mounted filesystem with ordered data mode.

mvh,
A
-- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
