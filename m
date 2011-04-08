Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE4688D003B
	for <linux-mm@kvack.org>; Fri,  8 Apr 2011 09:23:46 -0400 (EDT)
Received: by fxm18 with SMTP id 18so3351294fxm.14
        for <linux-mm@kvack.org>; Fri, 08 Apr 2011 06:23:42 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/2] make new alloc_pages_exact()
References: <20110407172104.1F8B7329@kernel> <20110407172105.831B9A0A@kernel>
 <op.vtmcx9kd3l0zgt@mnazarewicz-glaptop> <1302268786.8184.6879.camel@nimitz>
Date: Fri, 08 Apr 2011 15:23:40 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtmfhqyh3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1302268786.8184.6879.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

>> On Thu, 07 Apr 2011 19:21:05 +0200, Dave Hansen wrote:
>>>  		while (used < alloc_end) {
>>> -			free_page(used);
>>> -			used += PAGE_SIZE;
>>> +			__free_page(used);
>>> +			used++;
>>>  		}

> On Fri, 2011-04-08 at 14:28 +0200, Michal Nazarewicz wrote:
>> Have you thought about moving this loop to a separate function, ie.
>> _free_page_range(start, end)?  I'm asking because this loop appears
>> in two places and my CMA would also benefit from such a function.

On Fri, 08 Apr 2011 15:19:46 +0200, Dave Hansen wrote:
> Sounds like a good idea to me.  Were you thinking start/end 'struct
> page's as arguments?

Either that or (struct page *start, unsigned nr_pages).

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
