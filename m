Subject: Re: Support for sectorsizes > 4KB ?
Date: Wed, 6 Mar 2002 22:53:01 +0000 (GMT)
In-Reply-To: <XFMail.20020306084829.R.Oehler@GDAmbH.com> from "Ralf Oehler" at Mar 06, 2002 08:48:29 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E16ikHN-0008T9-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ralf Oehler <R.Oehler@GDAmbH.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scsi <linux-scsi@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> In the not-so-far future there will occure MO media on the market with
> 40 to 120 Gigabytes of capacity and sectorsizes of 8 KB and maybe more.
> It's called "UDO" technology.
> 
> Is there any way to support block devices with sectors larger than 4KB =
> ?

The scsi layer itself doesn't mind, but the page caches do. Once your
block size exceeds the page size you hit a wall of memory fragmentation
issues. Given that M/O media is relatively slow I'd be inclined to say
write an sd like driver (smo or similar) which does reblocking and also
knows a bit more about other M/O drive properties.

Alan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
