Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3F06B0253
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 21:11:01 -0400 (EDT)
Received: by qkei195 with SMTP id i195so42320521qke.3
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:11:01 -0700 (PDT)
Received: from mail-qg0-x230.google.com (mail-qg0-x230.google.com. [2607:f8b0:400d:c04::230])
        by mx.google.com with ESMTPS id 81si4511249qgx.77.2015.07.01.18.10.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 18:11:00 -0700 (PDT)
Received: by qgat90 with SMTP id t90so7938092qga.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 18:10:59 -0700 (PDT)
Date: Wed, 1 Jul 2015 21:10:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 22/51] writeback: add {CONFIG|BDI_CAP|FS}_CGROUP_WRITEBACK
Message-ID: <20150702011056.GC26440@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-23-git-send-email-tj@kernel.org>
 <20150630093751.GH7252@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150630093751.GH7252@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello, Jan.

On Tue, Jun 30, 2015 at 11:37:51AM +0200, Jan Kara wrote:
> Hum, you later changed this to use a per-sb flag instead of a per-fs-type
> flag, right? We could do it as well here but OK.

The commits were already in stable branch at that point and landed in
mainline during this merge window, so I'm afraid the review points
will have to be addressed as additional patches.

> One more question - what does prevent us from supporting CGROUP_WRITEBACK
> for all bdis capable of writeback? I guess the reason is that currently
> blkcgs are bound to request_queue and we have to have blkcg(s) for
> CGROUP_WRITEBACK to work, am I right? But in principle tracking writeback
> state and doing writeback per memcg doesn't seem to be bound to any device
> properties so we could do that right?

The main issue is that cgroup should somehow know how the processes
are mapped to the underlying IO layer - the IO domain should somehow
be defined.  We can introduce an intermediate abstraction which maps
to blkcg and whatever other cgroup controllers which may define cgroup
IO domains but given that such cases would be fairly niche, I think
we'd be better off making those corner cases represent themselves
using blkcg rather than introducing an additional layer.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
