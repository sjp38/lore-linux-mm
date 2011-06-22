Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 91249900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 12:04:48 -0400 (EDT)
Received: by yxn22 with SMTP id 22so498133yxn.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 09:04:45 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [Linaro-mm-sig] [PATCH 08/10] mm: cma: Contiguous Memory
 Allocator added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106221442.20848.arnd@arndb.de>
 <003701cc30de$7a159710$6e40c530$%szyprowski@samsung.com>
 <201106221539.24044.arnd@arndb.de>
Date: Wed, 22 Jun 2011 18:04:39 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vxhix1zu3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <201106221539.24044.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Arnd Bergmann <arnd@arndb.de>
Cc: 'Hans Verkuil' <hverkuil@xs4all.nl>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jesse Barker' <jesse.barker@linaro.org>, 'Mel
 Gorman' <mel@csn.ul.ie>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Andrew
 Morton' <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

On Wed, 22 Jun 2011 15:39:23 +0200, Arnd Bergmann <arnd@arndb.de> wrote:
> Why that? I would expect you can do the same that hugepages (used to) do
> and just attempt high-order allocations. If they succeed, you can add  
> them as a CMA region and free them again, into the movable set of pages,  
> otherwise you just fail the  request from user space when the memory is
> already fragmented.

Problem with that is that CMA needs to have whole pageblocks allocated
and buddy can allocate at most half a pageblock.

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
