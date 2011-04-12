Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DEC888D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 06:36:32 -0400 (EDT)
Received: by bwz17 with SMTP id 17so7906480bwz.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 03:36:30 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 2/3] make new alloc_pages_exact()
References: <20110411220345.9B95067C@kernel> <20110411220346.2FED5787@kernel>
 <20110411152223.3fb91a62.akpm@linux-foundation.org>
Date: Tue, 12 Apr 2011 12:28:19 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vttl1ho83l0zgt@mnazarewicz-glaptop>
In-Reply-To: <20110411152223.3fb91a62.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>

> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>> +void __free_pages_exact(struct page *page, size_t nr_pages)
>> +{
>> +	struct page *end = page + nr_pages;
>> +
>> +	while (page < end) {
>> +		__free_page(page);
>> +		page++;
>> +	}
>> +}
>> +EXPORT_SYMBOL(__free_pages_exact);

On Tue, 12 Apr 2011 00:22:23 +0200, Andrew Morton wrote:
> Really, this function duplicates release_pages().

It requires an array of pointers to pages which is not great though if one
just wants to free a contiguous sequence of pages.

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
