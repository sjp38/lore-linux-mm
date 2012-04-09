Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 745FA6B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 09:00:44 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Mon, 9 Apr 2012 13:00:34 +0000
References: <201203301744.16762.arnd@arndb.de> <006f01cd1623$ac4a2860$04de7920$%jeong@samsung.com> <4F8299B4.5090909@kernel.org>
In-Reply-To: <4F8299B4.5090909@kernel.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201204091300.34304.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: =?utf-8?q?=EC=A0=95=ED=9A=A8=EC=A7=84?= <syr.jeong@samsung.com>, 'Alex Lemberg' <Alex.Lemberg@sandisk.com>, linaro-kernel@lists.linaro.org, 'Rik van Riel' <riel@redhat.com>, linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org, "'Luca Porzio (lporzio)'" <lporzio@micron.com>, linux-mm@kvack.org, kernel-team@android.com, 'Yejin Moon' <yejin.moon@samsung.com>, 'Hugh Dickins' <hughd@google.com>, 'Yaniv Iarovici' <Yaniv.Iarovici@sandisk.com>, cpgs@samsung.com

On Monday 09 April 2012, Minchan Kim wrote:
> > 
> > Regarding swap page size:
> > Actually, I can't guarantee the optimal size of different eMMC in the industry, because it depends on NAND page size an firmware implementation inside eMMC. In case of SAMSUNG eMMC, 8KB page size and 512KB block size(erase unit) is current implementation.
> > I think that the multiple of 8KB page size align with 512KB is good for SAMSUNG eMMC.
> > If swap system use 512KB page and issue Discard/Trim align with 512KB, eMMC make best performance as of today. However, large page size in swap partition may not best way in Linux system level.
> > I'm not sure that the best page size between Swap system and eMMC device.
> 
> 
> The variety is one of challenges for removing GC generally. ;-(.
> I don't like manual setting through /sys/block/xxx because it requires
> that user have to know nand page size and erase block size but it's not
> easy to know to normal user.
> Arnd. What's your plan to support various flash storages effectively?

My preference would be to build the logic to detect the sizes into mkfs
and mkswap and encode them in the superblock in new fields. I don't think
we can trust any data that a device reports right now because operating
systems have ignored it in the past and either someone has forgotten to
update the fields after moving to new technology (eMMC), or the data can
not be encoded correctly according to the spec (SD, USB).

System builders for embedded systems can then make sure that they get
it right for the hardware they use, and we can try our best to help
that process.

	Ard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
