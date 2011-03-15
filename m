Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC668D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:43:39 -0400 (EDT)
Received: by iwl42 with SMTP id 42so235444iwl.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:43:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110315111641.3520.A69D9226@jp.fujitsu.com>
References: <1300154014.2337.74.camel@sli10-conroe>
	<AANLkTin2h0YFe70vYj7cExAJbbPS+oDjvfunfGPNZfB1@mail.gmail.com>
	<20110315111641.3520.A69D9226@jp.fujitsu.com>
Date: Tue, 15 Mar 2011 11:43:37 +0900
Message-ID: <AANLkTi=1hd71TS1x48PeDyFCSJGK8_1H-oPkA64HEH2S@mail.gmail.com>
Subject: Re: [PATCH 2/2 v4]mm: batch activate_page() to reduce lock contention
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 15, 2011 at 11:32 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> >> Why do we need CONFIG_SMP in only activate_page_pvecs?
>> >> The per-cpu of activate_page_pvecs consumes lots of memory in UP?
>> >> I don't think so. But if it consumes lots of memory, it's a problem
>> >> of per-cpu.
>> > No, not too much memory.
>> >
>> >> I can't understand why we should hanlde activate_page_pvecs specially.
>> >> Please, enlighten me.
>> > Not it's special. akpm asked me to do it this time. Reducing little
>> > memory is still worthy anyway, so that's it. We can do it for other
>> > pvecs too, in separate patch.
>>
>> Understandable but I don't like code separation by CONFIG_SMP for just
>> little bit enhance of memory usage. In future, whenever we use percpu,
>> do we have to implement each functions for both SMP and non-SMP?
>> Is it desirable?
>> Andrew, Is it really valuable?
>>
>> If everybody agree, I don't oppose such way.
>> But now I vote code cleanness than reduce memory footprint.
>
> FWIW, The ifdef was added for embedded concern. and I believe you are
> familiar with modern embedded trend than me. then, I have no objection
> to remove it if you don't need it.

I am keen in binary size but at least in this case, the benefit isn't
big, I think.
I hope we would care of code cleanness and latency of irq than memory
footprint in this time.

>
> Thanks.
>
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
