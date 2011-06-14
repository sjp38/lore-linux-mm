Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 037116B00EA
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 09:55:25 -0400 (EDT)
Received: by eyd9 with SMTP id 9so2819133eyd.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:55:21 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106101821.50437.arnd@arndb.de>
 <006a01cc29a9$1394c330$3abe4990$%szyprowski@samsung.com>
 <201106141549.29315.arnd@arndb.de>
Date: Tue, 14 Jun 2011 15:55:19 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vw2jmhir3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <201106141549.29315.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

On Tue, 14 Jun 2011 15:49:29 +0200, Arnd Bergmann <arnd@arndb.de> wrote:
> Please explain the exact requirements that lead you to defining multiple
> contexts.

Some devices may have access only to some banks of memory.  Some devices
may use different banks of memory for different purposes.

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
