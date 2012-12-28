Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 38C6A6B005D
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:42:25 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id h16so9898147oag.5
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 06:42:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50DCD4CB.50205@oracle.com>
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com>
	<1356293711-23864-2-git-send-email-sasha.levin@oracle.com>
	<alpine.DEB.2.00.1212271423210.18214@chino.kir.corp.google.com>
	<50DCCE5A.4000805@oracle.com>
	<alpine.DEB.2.00.1212271502070.23127@chino.kir.corp.google.com>
	<50DCD4CB.50205@oracle.com>
Date: Fri, 28 Dec 2012 23:42:24 +0900
Message-ID: <CAAmzW4MhCyYkdpOaHnJtoMoJeFsXQJXN=Cpo3s67=s+id-hrMg@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm, bootmem: panic in bootmem alloc functions even if
 slab is available
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Sasha.

2012/12/28 Sasha Levin <sasha.levin@oracle.com>:
> On 12/27/2012 06:04 PM, David Rientjes wrote:
>> On Thu, 27 Dec 2012, Sasha Levin wrote:
>>
>>> That's exactly what happens with the patch. Note that in the current upstream
>>> version there are several slab checks scattered all over.
>>>
>>> In this case for example, I'm removing it from __alloc_bootmem_node(), but the
>>> first code line of__alloc_bootmem_node_nopanic() is:
>>>
>>>         if (WARN_ON_ONCE(slab_is_available()))
>>>                 return kzalloc(size, GFP_NOWAIT);
>>>
>>
>> You're only talking about mm/bootmem.c and not mm/nobootmem.c, and notice
>> that __alloc_bootmem_node() does not call __alloc_bootmem_node_nopanic(),
>> it calls ___alloc_bootmem_node_nopanic().
>
> Holy cow, this is an underscore hell.
>
>
> Thanks,
> Sasha
>

I have a different idea.
How about removing fallback allocation in bootmem.c completely?
I don't know why it is there exactly.
But, warning for 'slab_is_available()' is there for a long time.
So, most people who misuse fallback allocation change their code adequately.
I think that removing fallback at this time is valid. Isn't it?

Fallback allocation may cause possible bug.
If someone free a memory from fallback allocation,
it can't be handled properly.

So, IMHO, at this time, we should remove fallback allocation in
bootmem.c entirely.
Please let me know what I misunderstand.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
