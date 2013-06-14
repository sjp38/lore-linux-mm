Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id BDD876B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 12:52:42 -0400 (EDT)
Message-ID: <51BB4A53.4000505@yandex-team.ru>
Date: Fri, 14 Jun 2013 20:52:35 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
References: <51BB1802.8050108@yandex-team.ru> <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com> <51BB33FE.1020403@yandex-team.ru> <0000013f43718d4d-7bb260e7-8115-4891-bb26-6febacb7169d-000000@email.amazonses.com>
In-Reply-To: <0000013f43718d4d-7bb260e7-8115-4891-bb26-6febacb7169d-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, David Rientjes <rientjes@google.com>, glommer@gmail.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 14.06.2013 20:08, Christoph Lameter wrote:
> On Fri, 14 Jun 2013, Roman Gushchin wrote:
>
>> But there is an actual problem, that this patch solves.
>> Sometimes I saw the following issue on some machines:
>> all CPUs are performing compaction, system time is about 80%,
>> system is completely unreliable. It occurs only on machines
>> with specific workload (distributed data storage system, so,
>> intensive disk i/o is performed). A system can fall into
>> this state fast and unexpectedly or by progressive degradation.
>
> Well that is not a slab allocator specific issue but related to compaction
> concurrency. Likely cache line contention is causing a severe slowday. But
> that issue could be triggered by any subsystem that does lots of memory
> allocations. I would suggest that we try to address the problem in the
> compaction logic rather than modifying allocators.

I agree, that it's good to address the original issue. But I'm not sure,
that it's a compaction issue. If someone wants to participate here,
I can provide more information. The main problem here is that it's
__very__ hard to reproduce the issue.

But, I think, all that shouldn't stop us from modifying the allocator.
Falling back to minimal order is in any case better than running
direct compaction. Just because it's faster. Am I wrong?

Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
