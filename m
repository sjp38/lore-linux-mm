Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id D4CF36B00D6
	for <linux-mm@kvack.org>; Tue,  7 May 2013 11:10:33 -0400 (EDT)
Received: by mail-bk0-f52.google.com with SMTP id q16so361371bkw.11
        for <linux-mm@kvack.org>; Tue, 07 May 2013 08:10:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130507134004.GB9497@dhcp22.suse.cz>
References: <1367768477-4360-1-git-send-email-handai.szj@taobao.com>
	<20130507134004.GB9497@dhcp22.suse.cz>
Date: Tue, 7 May 2013 23:10:31 +0800
Message-ID: <CAFj3OHVVPLQnOKFFdV6pu7mP=8W6mKUusvaBU8aspRZeUNBaOw@mail.gmail.com>
Subject: Re: [PATCH 1/3] memcg: correct RESOURCE_MAX to ULLONG_MAX and rename
 it to a better one
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, jeff.liu@oracle.com, Sha Zhengju <handai.szj@taobao.com>

Hi Michal,

On Tue, May 7, 2013 at 9:40 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Sun 05-05-13 23:41:17, Sha Zhengju wrote:
>> Current RESOURCE_MAX(unlimited) is ULONG_MAX, but we can set a bigger value
>
> You have a typo here. The current limit is LLONG_MAX
>
>> than it which is strange. This patch fix it to UULONG_MAX.
>
> and the new one is ULLONG_MAX

Oops... It was most thoughtless of me.

>
>> Notice that this change will affect user output of default *.limit_in_bytes:
>> before change:
>> $ cat /memcg/memory.limit_in_bytes
>> 9223372036854775807
>>
>> after change:
>> $ cat /memcg/memory.limit_in_bytes
>> 18446744073709551615
>>
>> But it doesn't alter the API in term of input - we can still use
>> "echo -1 > *.limit_in_bytes" to reset the numbers to "unlimited".
>>
>> Thanks the suggestions from Andrew and Daisuke Nishimura!
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>
> For the default change
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

>
>> ---
>>  include/linux/res_counter.h |    2 +-
>>  kernel/res_counter.c        |    8 ++++----
>>  mm/memcontrol.c             |    4 ++--
>>  net/ipv4/tcp_memcontrol.c   |   10 +++++-----
>>  4 files changed, 12 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index c230994..d7e9056 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -54,7 +54,7 @@ struct res_counter {
>>       struct res_counter *parent;
>>  };
>>
>> -#define RESOURCE_MAX (unsigned long long)LLONG_MAX
>> +#define RES_COUNTER_MAX ULLONG_MAX
>
> I do not think the renaming is worth bothering but if you feel it is a
> better match then just do it in a separate patch, please.

I've received comments from Andrew that he suggested we had better
rename it since it is too general. (Sorry, it's my fault that I didn't
mention the change log from V1, I will take care next time. The
previous discussion is here:
http://www.spinics.net/lists/cgroups/msg06788.html). I think we might
as well do it and I'll separate it in next turn.

--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
