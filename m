Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 456886B0074
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:59:58 -0400 (EDT)
Received: by ggm4 with SMTP id 4so8157806ggm.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 08:59:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4NGinc=7qEwhAH354Q7thkYy-HzpRNfVLtfaax4CEBB=g@mail.gmail.com>
References: <1340389359-2407-1-git-send-email-js1304@gmail.com>
	<1340390729-2821-1-git-send-email-js1304@gmail.com>
	<CAOJsxLHSboF0rQdGv8bdgGtinBz5dTo+omQbUnj9on_ewzgNAQ@mail.gmail.com>
	<CAAmzW4OdDhn5C_vfMhu3ejzzcXmCCt6r0h=nXUqKJaNYZxg8Bw@mail.gmail.com>
	<CAOJsxLGBxeu2sE-wDT+YNyVipmXiPj7Gvmmdo-0zGmJObp2zxg@mail.gmail.com>
	<CAAmzW4NGinc=7qEwhAH354Q7thkYy-HzpRNfVLtfaax4CEBB=g@mail.gmail.com>
Date: Wed, 4 Jul 2012 18:59:57 +0300
Message-ID: <CAOJsxLFwtwWHP8At6B8t0o6mKFKKfo6e7CEZj5Zi2AROgyMcfw@mail.gmail.com>
Subject: Re: [PATCH 1/3 v2] slub: prefetch next freelist pointer in __slab_alloc()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, David Rientjes <rientjes@google.com>

On Wed, Jul 4, 2012 at 6:45 PM, JoonSoo Kim <js1304@gmail.com> wrote:
>> Prefetching can also have negative effect on overall performance:
>>
>> http://lwn.net/Articles/444336/
>
> Thanks for good article which is very helpful to me.
>
>> That doesn't seem like that obvious win to me... Eric, Christoph?
>
> Could you tell me how I test this patch more deeply, plz?
> I am a kernel newbie and in the process of learning.
> I doesn't know what I can do more for this.
> I googling previous patch related to slub, some people use netperf.
>
> Just do below is sufficient?
> How is this test related to slub?
>
> for in in `seq 1 32`
> do
>  netperf -H 192.168.0.8 -v 0 -l -100000 -t TCP_RR > /dev/null &
> done
> wait

The networking subsystem is sensitive to slab allocator performance
which makes netperf an interesting benchmark, that's all.

As for slab benchmarking, you might want to look at what Mel Gorman
has done in the past:

https://lkml.org/lkml/2009/2/16/252

For something like prefetch optimization, you'd really want to see a
noticeable win in some benchmark. The kind of improvement you're
seeing with your patch is likely to be lost in the noise - or even
worse, cause negative performance for real world workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
