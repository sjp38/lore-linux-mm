Received: by uproxy.gmail.com with SMTP id s2so60592uge
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 21:24:21 -0800 (PST)
Message-ID: <aec7e5c30602082124u75c20e1eg85e639278e7364a0@mail.gmail.com>
Date: Thu, 9 Feb 2006 14:24:21 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <43EABC4D.7000900@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1139381183.22509.186.camel@localhost>
	 <43EAA0F4.2060208@jp.fujitsu.com>
	 <aec7e5c30602081857t65e58eb7l58299dcde36e6949@mail.gmail.com>
	 <43EAB395.6000603@jp.fujitsu.com>
	 <aec7e5c30602081938w1d593309h5422abcef597f4bf@mail.gmail.com>
	 <43EABC4D.7000900@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

On 2/9/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Magnus Damm wrote:
> > With my proposal (Removing type B bits), if you can guarantee that all
> > your zones have a start address and a size that is aligned to (1 <<
> > (PAGE_SHIFT * 2)), then the following code should be possible:
> >
> > struct zone *page_zone(struct page *page)
> > {
> >   struct page *parent = virt_to_page(page);
> >
> >   return (struct zone *)parent->mapping;
> > }
> >
>
> I think "Why do this" is important. Just for increasing space of page->flags
> is not attractive to me. And I think your proposal will adds a extra limitation
> to memmap and page<->zone linkage.
> IMHO, it will adds another complexity to the kernel.

Yes, it will make the relationship between zones and memmap more
complex. The only reason to implement this idea would be to save space
by removing page->flags. But the move of type A bits will probably
result in more cache misses so it is probably not worth it.

Thanks for your input,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
