Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A77796B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 08:54:48 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Mon, 9 Apr 2012 12:54:39 +0000
References: <201203301744.16762.arnd@arndb.de> <4F8245EA.6000600@kernel.org> <006f01cd1623$ac4a2860$04de7920$%jeong@samsung.com>
In-Reply-To: <006f01cd1623$ac4a2860$04de7920$%jeong@samsung.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <201204091254.39380.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?q?=EC=A0=95=ED=9A=A8=EC=A7=84?= <syr.jeong@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Alex Lemberg' <Alex.Lemberg@sandisk.com>, linaro-kernel@lists.linaro.org, 'Rik van Riel' <riel@redhat.com>, linux-mmc@vger.kernel.org, linux-kernel@vger.kernel.org, "'Luca Porzio (lporzio)'" <lporzio@micron.com>, linux-mm@kvack.org, kernel-team@android.com, 'Yejin Moon' <yejin.moon@samsung.com>, 'Hugh Dickins' <hughd@google.com>, 'Yaniv Iarovici' <Yaniv.Iarovici@sandisk.com>, cpgs@samsung.com

On Monday 09 April 2012, i ?i??i?? wrote:
> If swap system use 512KB page and issue Discard/Trim align with 512KB, eMMC make best
> performance as of today. However, large page size in swap partition may not best way
> in Linux system level.
> I'm not sure that the best page size between Swap system and eMMC device.

Can you explain the significance of the 512KB size? I've seen devices report 512KB
erase size, although measurements clearly showed an erase block size of 8MB and I
do not understand this discprepancy.

Right now, we always send discards of 1MB clusters to the device, which does what
you want, although I'm not sure if those clusters are naturally aligned to the start
of the partition. Obviously this also requires aligning the start of the partition
to the erase block size, but most devices should already get that right nowadays.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
