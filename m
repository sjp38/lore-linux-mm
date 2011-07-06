Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 432EC9000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 10:48:57 -0400 (EDT)
Received: by vxg38 with SMTP id 38so7267016vxg.14
        for <linux-mm@kvack.org>; Wed, 06 Jul 2011 07:48:55 -0700 (PDT)
Date: Wed, 6 Jul 2011 10:37:37 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [Linaro-mm-sig] [PATCH 6/8] drivers: add Contiguous Memory
 Allocator
In-Reply-To: <20110706142345.GC8286@n2100.arm.linux.org.uk>
Message-ID: <alpine.LFD.2.00.1107061034200.14596@xanadu.home>
References: <1309851710-3828-1-git-send-email-m.szyprowski@samsung.com> <20110705113345.GA8286@n2100.arm.linux.org.uk> <006301cc3be4$daab1850$900148f0$%szyprowski@samsung.com> <201107061609.29996.arnd@arndb.de>
 <20110706142345.GC8286@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Arnd Bergmann <arnd@arndb.de>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, 'Mel Gorman' <mel@csn.ul.ie>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, 'Michal Nazarewicz' <mina86@mina86.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Wed, 6 Jul 2011, Russell King - ARM Linux wrote:

> Another issue is that when a platform has restricted DMA regions,
> they typically don't fall into the highmem zone.  As the dmabounce
> code allocates from the DMA coherent allocator to provide it with
> guaranteed DMA-able memory, that would be rather inconvenient.

Do we encounter this in practice i.e. do those platforms requiring large 
contiguous allocations motivating this work have such DMA restrictions?


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
