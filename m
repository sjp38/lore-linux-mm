Date: Sat, 7 Jun 2003 17:56:49 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm6
Message-Id: <20030607175649.6bf3813b.akpm@digeo.com>
In-Reply-To: <873cilz9os.fsf@lapper.ihatent.com>
References: <20030607151440.6982d8c6.akpm@digeo.com>
	<873cilz9os.fsf@lapper.ihatent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Hoogerhuis <alexh@ihatent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

Alexander Hoogerhuis <alexh@ihatent.com> wrote:
>
> Andrew Morton <akpm@digeo.com> writes:
> >
> > [SNIP]
> >
> 
> It builds nicely here and runs nicely so far, but my USB-drive still
> blows up after a few gigs

Is that usb-storage?  There seem to have been a few reports of
erratic behaviour lately.

> and I have this one when plugging it in:
> 
> Attached scsi generic sg0 at scsi0, channel 0, id 0, lun 0,  type 0
> spurious 8259A interrupt: IRQ7.
> SCSI device sda: 490232832 512-byte hdwr sectors (250999 MB)
> sda: cache data unavailable
> sda: assuming drive cache: write through
>  /dev/scsi/host0/bus0/target0/lun0: p1
> devfs_mk_dir(scsi/host0/bus0/target0/lun0): could not append to dir: ea549820 "target0"

Maybe Christph can decode this one for us.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
