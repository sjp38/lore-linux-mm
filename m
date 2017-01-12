Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 24E236B0261
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:58:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so5562005wmi.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 07:58:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y23si7633696wra.86.2017.01.12.07.58.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 07:58:06 -0800 (PST)
Date: Thu, 12 Jan 2017 16:57:43 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170112155743.GN12081@suse.cz>
Reply-To: dsterba@suse.cz
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Hariprasad S <hariprasad@chelsio.com>, Santosh Raspatur <santosh@chelsio.com>, Kees Cook <keescook@chromium.org>, Johannes Weiner <hannes@cmpxchg.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Anton Vorontsov <anton@enomsg.org>, Eric Dumazet <eric.dumazet@gmail.com>, Ilya Dryomov <idryomov@gmail.com>, Kent Overstreet <kent.overstreet@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, David Rientjes <rientjes@google.com>, Andreas Dilger <andreas.dilger@intel.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Tony Luck <tony.luck@intel.com>, Alexei Starovoitov <ast@kernel.org>, linux-mm@kvack.org, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Ben Skeggs <bskeggs@redhat.com>, Zheng Yan <zyan@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Michal Hocko <MHocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Thu, Jan 12, 2017 at 04:37:16PM +0100, Michal Hocko wrote:
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

For the btrfs bits,

Acked-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
