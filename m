Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9373D6B007E
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 12:09:07 -0400 (EDT)
Received: by wyg36 with SMTP id 36so83917wyg.14
        for <linux-mm@kvack.org>; Wed, 06 Jul 2011 09:09:04 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 6/8] drivers: add Contiguous Memory Allocator
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com>
 <201107061609.29996.arnd@arndb.de>
 <20110706142345.GC8286@n2100.arm.linux.org.uk>
 <201107061651.49824.arnd@arndb.de>
 <20110706154857.GG8286@n2100.arm.linux.org.uk>
 <alpine.DEB.2.00.1107061100290.17624@router.home>
Date: Wed, 06 Jul 2011 18:09:00 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vx7ghajd3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <alpine.DEB.2.00.1107061100290.17624@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>, Christoph Lameter <cl@linux.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita
 Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-media@vger.kernel.org

On Wed, 06 Jul 2011 18:05:00 +0200, Christoph Lameter <cl@linux.com> wrote:
> ZONE_DMA is a zone for memory of legacy (crippled) devices that cannot  
> DMA into all of memory (and so is ZONE_DMA32).  Memory from ZONE_NORMAL
> can be used for DMA as well and a fully capable device would be expected
> to handle any memory in the system for DMA transfers.
>
> "guaranteed" dmaable memory? DMA abilities are device specific. Well  
> maybe you can call ZONE_DMA memory to be guaranteed if you guarantee
> that any device must at mininum be able to perform DMA into ZONE_DMA
> memory. But there may not be much of that memory around so you would
> want to limit the use of that scarce resource.

As pointed in Marek's other mail, this reasoning is not helping in any
way.  In case of video codec on various Samsung devices (and from some
other threads this is not limited to Samsung), the codec needs separate
buffers in separate memory banks.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
