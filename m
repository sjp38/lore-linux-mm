Message-ID: <43EAB395.6000603@jp.fujitsu.com>
Date: Thu, 09 Feb 2006 12:14:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] Removing page->flags
References: <1139381183.22509.186.camel@localhost>	 <43EAA0F4.2060208@jp.fujitsu.com> <aec7e5c30602081857t65e58eb7l58299dcde36e6949@mail.gmail.com>
In-Reply-To: <aec7e5c30602081857t65e58eb7l58299dcde36e6949@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> Hi Kamezawa-san,
> 
> On 2/9/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Magnus Damm wrote:
>>> [RFC] Removing page-flags
>>>
>>> Moving type A bits:
>>>
>>> Instead of keeping the bits together, we spread them out and store a
>>> pointer to them from pg_data_t.
>>>
>> This will annoy people who has a job to look into crash-dump's vmcore..like me ;)
>> so, I don't like this idea.
> 
> Hehe, gotcha. =) I also wonder how well it would work with your zone patches.
> 
My layout-free-zone patches are not affected by this if you use pgdat/section to
preserve page-flags.

To be honest, I'd like to do this
==
struct zone *page_zone(struct page *page)
{
	return page->zone;
}
==
But this increases size of memmap awfully ;( and I can't.
Current zone-indexing in page-flags is well saving memory space, I think.
-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
