Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5FAA76B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:45:57 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so8144355ghr.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 08:45:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLGBxeu2sE-wDT+YNyVipmXiPj7Gvmmdo-0zGmJObp2zxg@mail.gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340390729-2821-1-git-send-email-js1304@gmail.com>
	<CAOJsxLHSboF0rQdGv8bdgGtinBz5dTo+omQbUnj9on_ewzgNAQ@mail.gmail.com>
	<CAAmzW4OdDhn5C_vfMhu3ejzzcXmCCt6r0h=nXUqKJaNYZxg8Bw@mail.gmail.com>
	<CAOJsxLGBxeu2sE-wDT+YNyVipmXiPj7Gvmmdo-0zGmJObp2zxg@mail.gmail.com>
Date: Thu, 5 Jul 2012 00:45:56 +0900
Message-ID: <CAAmzW4NGinc=7qEwhAH354Q7thkYy-HzpRNfVLtfaax4CEBB=g@mail.gmail.com>
Subject: Re: [PATCH 1/3 v2] slub: prefetch next freelist pointer in __slab_alloc()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, David Rientjes <rientjes@google.com>

2012/7/5 Pekka Enberg <penberg@kernel.org>:
>> 2012/7/4 Pekka Enberg <penberg@kernel.org>:
>>> Well, can you show improvement in any benchmark or workload?
>>> Prefetching is not always an obvious win and the reason we merged
>>> Eric's patch was that he was able to show an improvement in hackbench.
>
> On Wed, Jul 4, 2012 at 5:30 PM, JoonSoo Kim <js1304@gmail.com> wrote:
>> I thinks that this patch is perfectly same effect as Eric's patch, so
>> doesn't include benchmark result.
>> Eric's patch which add "prefetch instruction" in fastpath works for
>> second ~ last object of cpu slab.
>> This patch which add "prefetch instrunction" in slowpath works for
>> first object of cpu slab.
>
> Prefetching can also have negative effect on overall performance:
>
> http://lwn.net/Articles/444336/
>

Thanks for good article which is very helpful to me.

> That doesn't seem like that obvious win to me... Eric, Christoph?

Could you tell me how I test this patch more deeply, plz?
I am a kernel newbie and in the process of learning.
I doesn't know what I can do more for this.
I googling previous patch related to slub, some people use netperf.

Just do below is sufficient?
How is this test related to slub?

for in in `seq 1 32`
do
 netperf -H 192.168.0.8 -v 0 -l -100000 -t TCP_RR > /dev/null &
done
wait

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
