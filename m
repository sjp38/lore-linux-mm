Date: Mon, 28 Apr 2003 00:26:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: questions on swapping
Message-ID: <20030428072655.GS30441@holomorphy.com>
References: <OF0FF471FA.CAEE07D7-ON65256D16.00277E63@celetron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF0FF471FA.CAEE07D7-ON65256D16.00277E63@celetron.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heerappa Hunje <hunjeh@celetron.com>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
> 1. I have problem in locating the source code of linux operating system
> because i dont know in which path it is kept. Pls suggest me the pathname.

ftp://ftp.kernel.org/pub/linux/kernel/v2.5/
	and
ftp://ftp.kernel.org/pub/linux/kernel/v2.4/

for the less adventurous


On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
> 2. let me know the different ways to connect the device drivers module to
> the kernel.

This is a bit too general to answer at all.


On Mon, Apr 28, 2003 at 12:46:15PM +0530, Heerappa Hunje wrote:
> 3. let me know where actually the space for SWAPPING, BUFFERS  are
> allocated. i mean whether they are in RAM Memory or Hard disk drive.

Buffers are in RAM, swap is on-disk.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
