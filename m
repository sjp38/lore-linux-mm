Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3323D6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 09:09:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id r23-v6so15037257wrc.2
        for <linux-mm@kvack.org>; Wed, 30 May 2018 06:09:54 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d18-v6si7759992edb.254.2018.05.30.06.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 06:09:53 -0700 (PDT)
Date: Wed, 30 May 2018 09:11:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/13] blkcg: add generic throttling mechanism
Message-ID: <20180530131159.GB4035@cmpxchg.org>
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-7-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529211724.4531-7-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, May 29, 2018 at 05:17:17PM -0400, Josef Bacik wrote:
> @@ -1099,6 +1099,11 @@ struct task_struct {
>  	unsigned int			memcg_nr_pages_over_high;
>  #endif
>  
> +#ifdef CONFIG_BLK_CGROUP
> +	struct request_queue		*throttle_queue;
> +	bool				use_memdelay;
> +#endif

Since you only touch use_memdelay from current, you can make this a
single bit and pack it with the other task flags farther up;
memcg_may_oom, no_cgroup_migration and friends.
