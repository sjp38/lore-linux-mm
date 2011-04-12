Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B2A63900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:59:03 -0400 (EDT)
Received: by bwz17 with SMTP id 17so8277719bwz.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 08:59:01 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
References: <20110411220345.9B95067C@kernel> <20110411220346.2FED5787@kernel>
 <20110411152223.3fb91a62.akpm@linux-foundation.org>
 <op.vttl1ho83l0zgt@mnazarewicz-glaptop> <1302620653.8321.1725.camel@nimitz>
Date: Tue, 12 Apr 2011 17:58:59 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vtt1clbd3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1302620653.8321.1725.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>

On Tue, 12 Apr 2011 17:04:13 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
wrote:

> On Tue, 2011-04-12 at 12:28 +0200, Michal Nazarewicz wrote:
>> > Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>> >> +void __free_pages_exact(struct page *page, size_t nr_pages)
>> >> +{
>> >> +	struct page *end = page + nr_pages;
>> >> +
>> >> +	while (page < end) {
>> >> +		__free_page(page);
>> >> +		page++;
>> >> +	}
>> >> +}
>> >> +EXPORT_SYMBOL(__free_pages_exact);
>>
>> On Tue, 12 Apr 2011 00:22:23 +0200, Andrew Morton wrote:
>> > Really, this function duplicates release_pages().
>>
>> It requires an array of pointers to pages which is not great though if  
>> one
>> just wants to free a contiguous sequence of pages.
>
> Actually, the various mem_map[]s _are_ arrays, at least up to
> MAX_ORDER_NR_PAGES at a time.  We can use that property here.

In that case, waiting eagerly for the new patch. :)

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
