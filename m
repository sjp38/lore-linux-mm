Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id A37316B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:19:08 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 65so27328088otq.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 00:19:08 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0061.outbound.protection.outlook.com. [104.47.2.61])
        by mx.google.com with ESMTPS id h49si8300093ote.229.2017.01.16.00.19.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Jan 2017 00:19:07 -0800 (PST)
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
From: Tariq Toukan <tariqt@mellanox.com>
Message-ID: <836c370c-f8ff-d682-f457-0ad0da622068@mellanox.com>
Date: Mon, 16 Jan 2017 10:18:48 +0200
MIME-Version: 1.0
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org



On 12/01/2017 5:37 PM, Michal Hocko wrote:
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
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: Andreas Dilger <andreas.dilger@intel.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: David Sterba <dsterba@suse.com>
> Cc: "Yan, Zheng" <zyan@redhat.com>
> Cc: Ilya Dryomov <idryomov@gmail.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Tariq Toukan <tariqt@mellanox.com>
For the mlx4 parts.

Regards.
Tariq

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
