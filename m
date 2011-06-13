Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 487046B0012
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:54:42 -0400 (EDT)
Date: Mon, 13 Jun 2011 11:54:37 -0700
From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [Linaro-mm-sig] [RFC 0/2] ARM: DMA-mapping & IOMMU integration
Message-ID: <20110613115437.62824f2f@jbarnes-desktop>
In-Reply-To: <BANLkTi=C6NKT94Fk6Rq6wmhndVixOqC6mg@mail.gmail.com>
References: <1306308920-8602-1-git-send-email-m.szyprowski@samsung.com>
	<BANLkTi=HtrFETnjk1Zu0v9wqa==r0OALvA@mail.gmail.com>
	<201106131707.49217.arnd@arndb.de>
	<BANLkTikR5AE=-wTWzrSJ0TUaks0_rA3mcg@mail.gmail.com>
	<20110613154033.GA29185@1n450.cable.virginmedia.net>
	<BANLkTikkCV=rWM_Pq6t6EyVRHcWeoMPUqw@mail.gmail.com>
	<BANLkTi=C6NKT94Fk6Rq6wmhndVixOqC6mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: M.K.Edwards@gmail.com
Cc: KyongHo Cho <pullip.cho@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Mon, 13 Jun 2011 10:55:59 -0700
"Michael K. Edwards" <m.k.edwards@gmail.com> wrote:

> As far as I can tell, there is not yet any way to get real
> cache-bypassing write-combining from userland in a mainline kernel,
> for x86/x86_64 or ARM. 

Well only if things are really broken.  sysfs exposes _wc resource
files to allow userland drivers to map a given PCI BAR using write
combining, if the underlying platform supports it.

Similarly, userland mapping of GEM objects through the GTT are supposed
to be write combined, though I need to verify this (we've had trouble
with it in the past).

-- 
Jesse Barnes, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
