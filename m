Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 465716B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 05:26:54 -0400 (EDT)
Received: by fxm18 with SMTP id 18so340001fxm.14
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 02:26:51 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory
 Allocator added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <20110614170158.GU2419@fooishbar.org>
 <BANLkTi=cJisuP8=_YSg4h-nsjGj3zsM7sg@mail.gmail.com>
 <201106142242.25157.arnd@arndb.de>
Date: Wed, 15 Jun 2011 11:26:47 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vw31uxxl3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <201106142242.25157.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Pfeffer <zach.pfeffer@linaro.org>, Arnd Bergmann <arnd@arndb.de>
Cc: Daniel Stone <daniels@collabora.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Tue, 14 Jun 2011 22:42:24 +0200, Arnd Bergmann <arnd@arndb.de> wrote:
> * We still need to solve the same problem in case of IOMMU mappings
>   at some point, even if today's hardware doesn't have this combination.
>   It would be good to use the same solution for both.

I don't think I follow.  What does IOMMU has to do with CMA?

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
