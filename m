Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0CF756B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:49:29 -0400 (EDT)
Message-ID: <4F838390.1080909@redhat.com>
Date: Mon, 09 Apr 2012 20:49:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: mapped pagecache pages vs unmapped pages
References: <37371333672160@webcorp7.yandex-team.ru> <4F7E9854.1020904@gmail.com> <12701333991475@webcorp7.yandex-team.ru> <4F8326FD.8020507@redhat.com> <8041334015453@webcorp4.yandex-team.ru> <4F837F6E.3010508@kernel.org>
In-Reply-To: <4F837F6E.3010508@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Alexey Ivanov <rbtz@yandex-team.ru>, "gnehzuil.lzheng@gmail.com" <gnehzuil.lzheng@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com

On 04/09/2012 08:31 PM, Minchan Kim wrote:
> 2012-04-10 i??i ? 8:50, Alexey Ivanov i?' e,?:
>
>> Did you consider making this ratio tunable, at least manually(i.e. via sysctl)?
>> I suppose we are not the only ones with almost-whole-ram-mmaped workload.
>
> Personally, I think it's not good approach.
> It depends on kernel's internal implemenatation which would be changed
> in future as we chagend it at 2.6.28.

I also believe that a tunable for this is not going to be
a very workable approach, for the simple reason that changing
the value does not make a predictable change in the effectiveness
of working set detection or protection.

> In my opinion, kernel just should do best effort to keep active working
> set except some critical pages which are code pages.

Johannes has some experimental code to measure refaults, and
calculate their distance in a multi-zone, multi-cgroup environment.

That would allow us to predictably place things in the working set
as required.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
