Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7C090015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 03:32:22 -0400 (EDT)
Received: by ywb26 with SMTP id 26so277458ywb.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 00:32:20 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory
 Allocator added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <000501cc2b2b$789a54b0$69cefe10$%szyprowski@samsung.com>
 <201106150937.18524.arnd@arndb.de> <201106220903.31065.hverkuil@xs4all.nl>
Date: Wed, 22 Jun 2011 09:32:13 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vxgu7zgo3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <201106220903.31065.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org, Hans Verkuil <hverkuil@xs4all.nl>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, 'Daniel Walker' <dwalker@codeaurora.org>, linux-mm@kvack.org, 'Mel Gorman' <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, 'Jesse Barker' <jesse.barker@linaro.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-media@vger.kernel.org, 'KAMEZAWA
 Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, 22 Jun 2011 09:03:30 +0200, Hans Verkuil <hverkuil@xs4all.nl>  
wrote:
> What I was wondering about is how this patch series changes the  
> allocation in case it can't allocate from the CMA pool. Will it
> attempt to fall back to a 'normal' allocation?

Unless Marek changed something since I wrote the code, which I doubt,
if CMA cannot obtain memory from CMA region, it will fail.

Part of the reason is that CMA lacks the knowledge where to allocate
memory from.  For instance, with the case of several memory banks,
it does not know which memory bank to allocate from.

It is, in my opinion, a task for a higher level functions (read:
DMA layer) to try another mechanism if CMA fails.

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
