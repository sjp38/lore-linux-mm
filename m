Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 62FC76B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:30:26 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so103766298pac.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:30:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r81si4281546pfi.191.2016.01.26.13.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 13:30:25 -0800 (PST)
Date: Tue, 26 Jan 2016 13:30:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcontrol: drop superfluous entry in the per-memcg
 stats array
Message-Id: <20160126133024.07f372dbf8935e03a3035269@linux-foundation.org>
In-Reply-To: <1453841729-29072-1-git-send-email-hannes@cmpxchg.org>
References: <1453841729-29072-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 26 Jan 2016 15:55:29 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> MEM_CGROUP_STAT_NSTATS is just a delimiter for cgroup1 statistics, not
> an actual array entry. Reuse it for the first cgroup2 stat entry, like
> in the event array.
> 
> ...
>
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -51,7 +51,7 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
>  	MEM_CGROUP_STAT_NSTATS,
>  	/* default hierarchy stats */
> -	MEMCG_SOCK,
> +	MEMCG_SOCK = MEM_CGROUP_STAT_NSTATS,
>  	MEMCG_NR_STAT,
>  };

The code looks a bit odd.  How come mem_cgroup_stat_names[] ends with
"swap"?  Should MEMCG_SOCK be in there at all?

And the naming is a bit sad.  "MEM_CGROUP_STAT_FILE_MAPPED" maps to
"mapped_file", not "file_mapped".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
