Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 607646B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:00:32 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x84so44737631oix.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:00:32 -0800 (PST)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id f194si3895900oib.27.2017.01.12.09.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 09:00:31 -0800 (PST)
Received: by mail-oi0-x236.google.com with SMTP id w204so30012877oiw.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:00:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
References: <20170112153717.28943-1-mhocko@kernel.org> <20170112153717.28943-6-mhocko@kernel.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 12 Jan 2017 09:00:30 -0800
Message-ID: <CAPcyv4jq0R4_NOau=Yqk3Y9Bzrpcr9U_N+RJbdRUdsxJiF9kvA@mail.gmail.com>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded variants
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Netdev <netdev@vger.kernel.org>

On Thu, Jan 12, 2017 at 7:37 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests < 64kB are basically never failing and invoke OOM killer to
> satisfy the allocation. This sounds too disruptive for something that
> has a reasonable fallback - the vmalloc. On the other hand those
> requests might fallback to vmalloc even when the memory allocator would
> succeed after several more reclaim/compaction attempts previously. There
> is no guarantee something like that happens though.
>
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.
>
[..]
> Cc: Dan Williams <dan.j.williams@intel.com>
[..]
>  drivers/nvdimm/dimm_devs.c                         |  5 +---

Acked-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
