Message-ID: <396C97F7.2AEE5FE7@augan.com>
Date: Wed, 12 Jul 2000 18:08:23 +0200
From: Roman Zippel <roman@augan.com>
MIME-Version: 1.0
Subject: Re: map_user_kiobuf problem in 2.4.0-test3
References: <396C9188.523658B9@sangate.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Mokryn <mark@sangate.com>
Cc: linux-kernel@vger.rutgers.edu, linux-scsi@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> On another interesting note: The raw devices I'm writing to are Fibre
> Channel drives controlled by a Qlogic 2200 adapter (in 2.2.14 I'm using
> the Qlogic driver). When writing large sequential blocks to a single
> drive, I reached 8MB/s when the memory was mapped to the high reserved
> region, while CPU utilization was down to about 5%. When the mapping was
> to PCI space, I was able to write at only 4MB/s, and CPU utilization was
> up to 60%!

The data is copied from a buffer to the pci device. DMA transfers going
directly to pci space is impossible without (small) changes to 2.2. 2.4
has the theoretic possibility to do it and checks already for that, but
how it should be done practically I'd like to know too.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
