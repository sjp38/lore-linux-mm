Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB896B019C
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 13:27:47 -0400 (EDT)
Received: by bkbzt12 with SMTP id zt12so1100176bkb.14
        for <linux-mm@kvack.org>; Thu, 08 Sep 2011 10:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1313764064-9747-8-git-send-email-m.szyprowski@samsung.com>
References: <1313764064-9747-1-git-send-email-m.szyprowski@samsung.com> <1313764064-9747-8-git-send-email-m.szyprowski@samsung.com>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Thu, 8 Sep 2011 13:27:22 -0400
Message-ID: <CAMjpGUch=ogFQwBLqOukKVnyh60600jw5tMq-KYeNGSZ2PLQpA@mail.gmail.com>
Subject: Re: [PATCH 7/8] ARM: integrate CMA with DMA-mapping subsystem
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Fri, Aug 19, 2011 at 10:27, Marek Szyprowski wrote:
> =C2=A0arch/arm/include/asm/device.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =
=C2=A03 +
> =C2=A0arch/arm/include/asm/dma-contiguous.h | =C2=A0 33 +++

seems like these would be good asm-generic/ additions rather than arm
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
