Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 22FE56B02FF
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 21:19:15 -0400 (EDT)
Message-ID: <4FE7BCAD.4090002@kernel.org>
Date: Mon, 25 Jun 2012 10:19:41 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com> <4FE27F15.8050102@kernel.org> <CAHGf_=pDw4axwG2tQ+B5hPks-sz2S5+G1Kk-=HSDmo=DSXOkEw@mail.gmail.com> <4FE2A937.6040701@kernel.org> <4FE2FCFB.4040808@jp.fujitsu.com> <4FE3C4E4.2050107@kernel.org> <4FE414A2.3000700@kernel.org> <4FE530F7.1060108@gmail.com>
In-Reply-To: <4FE530F7.1060108@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/23/2012 11:59 AM, KOSAKI Motohiro wrote:

> 
> One more.
> 
> 
>> +/*
>> + * NOTE:
>> + * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) direclty.
>> + * Instead, use {un}set_pageblock_isolate.
>> + */
>>  void set_pageblock_migratetype(struct page *page, int migratetype)
>>  {
>>         if (unlikely(page_group_by_mobility_disabled))
> 
> I don't think we need this comment. please just add BUG_ON.


It adds new condition check in __rmqueue_fallback.
If it's okay, no problem.

But as you know, calling MIGRATE_ISOLATE is very very rare and we can
make sure it's no problem on existing code. So the problem is future
user and I hope they can look at the code comment before using and we mm
have strong review system rather than other subsystem, I believe. :)

If you can't agree, I am willing to add BUG_ON but not sure others
like it. (Especially, Mel).



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
