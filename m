Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1D87A6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 12:58:42 -0400 (EDT)
Received: by fxm18 with SMTP id 18so5551346fxm.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 09:58:37 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 08/10] mm: cma: Contiguous Memory Allocator added
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <201106141549.29315.arnd@arndb.de> <op.vw2jmhir3l0zgt@mnazarewicz-glaptop>
 <201106141803.00876.arnd@arndb.de>
Date: Tue, 14 Jun 2011 18:58:35 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vw2r3xrj3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <201106141803.00876.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Mel Gorman' <mel@csn.ul.ie>, 'Jesse Barker' <jesse.barker@linaro.org>

>> On Tue, 14 Jun 2011 15:49:29 +0200, Arnd Bergmann <arnd@arndb.de> wrote:
>>> Please explain the exact requirements that lead you to defining  
>>> multiple contexts.

> On Tuesday 14 June 2011, Michal Nazarewicz wrote:
>> Some devices may have access only to some banks of memory.  Some devices
>> may use different banks of memory for different purposes.

On Tue, 14 Jun 2011 18:03:00 +0200, Arnd Bergmann wrote:
> For all I know, that is something that is only true for a few very  
> special Samsung devices,

Maybe.  I'm just answering your question. :)

Ah yes, I forgot that separate regions for different purposes could
decrease fragmentation.

> I would suggest going forward without having multiple regions:

Is having support for multiple regions a bad thing?  Frankly,
removing this support will change code from reading context passed
as argument to code reading context from global variable.  Nothing
is gained; functionality is lost.

> * Remove the registration of specific addresses from the initial patch
>   set (but keep the patch).
> * Add a heuristic plus command-line override to automatically come up
>   with a reasonable location+size for *one* CMA area in the system.

I'm not arguing those.

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
