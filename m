Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CD5296B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 21:22:47 -0400 (EDT)
Message-ID: <4F838BF4.7020104@kernel.org>
Date: Tue, 10 Apr 2012 10:25:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: mapped pagecache pages vs unmapped pages
References: <37371333672160@webcorp7.yandex-team.ru> <4F7E9854.1020904@gmail.com> <12701333991475@webcorp7.yandex-team.ru> <4F8326FD.8020507@redhat.com> <8041334015453@webcorp4.yandex-team.ru> <4F837F6E.3010508@kernel.org> <4F838390.1080909@redhat.com>
In-Reply-To: <4F838390.1080909@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, hannes@cmpxchg.org
Cc: Alexey Ivanov <rbtz@yandex-team.ru>, "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com

2012-04-10 i??i ? 9:49, Rik van Riel i?' e,?:

> On 04/09/2012 08:31 PM, Minchan Kim wrote:
>> 2012-04-10 i??i ? 8:50, Alexey Ivanov i?' e,?:
>>
>>> Did you consider making this ratio tunable, at least manually(i.e.
>>> via sysctl)?
>>> I suppose we are not the only ones with almost-whole-ram-mmaped
>>> workload.
>>
>> Personally, I think it's not good approach.
>> It depends on kernel's internal implemenatation which would be changed
>> in future as we chagend it at 2.6.28.
> 
> I also believe that a tunable for this is not going to be
> a very workable approach, for the simple reason that changing
> the value does not make a predictable change in the effectiveness
> of working set detection or protection.
> 
>> In my opinion, kernel just should do best effort to keep active working
>> set except some critical pages which are code pages.
> 
> Johannes has some experimental code to measure refaults, and
> calculate their distance in a multi-zone, multi-cgroup environment.
> 
> That would allow us to predictably place things in the working set
> as required.
> 


Hannes, it can help many people if you post your code. ;)


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
