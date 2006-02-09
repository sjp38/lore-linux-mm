Message-ID: <43EABC4D.7000900@jp.fujitsu.com>
Date: Thu, 09 Feb 2006 12:51:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] Removing page->flags
References: <1139381183.22509.186.camel@localhost>	 <43EAA0F4.2060208@jp.fujitsu.com>	 <aec7e5c30602081857t65e58eb7l58299dcde36e6949@mail.gmail.com>	 <43EAB395.6000603@jp.fujitsu.com> <aec7e5c30602081938w1d593309h5422abcef597f4bf@mail.gmail.com>
In-Reply-To: <aec7e5c30602081938w1d593309h5422abcef597f4bf@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> With my proposal (Removing type B bits), if you can guarantee that all
> your zones have a start address and a size that is aligned to (1 <<
> (PAGE_SHIFT * 2)), then the following code should be possible:
> 
> struct zone *page_zone(struct page *page)
> {
>   struct page *parent = virt_to_page(page);
> 
>   return (struct zone *)parent->mapping;
> }
> 

I think "Why do this" is important. Just for increasing space of page->flags
is not attractive to me. And I think your proposal will adds a extra limitation
to memmap and page<->zone linkage.
IMHO, it will adds another complexity to the kernel.

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
