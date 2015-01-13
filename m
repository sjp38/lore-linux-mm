Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id BCA486B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 18:20:34 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id vy18so5833569iec.9
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:20:34 -0800 (PST)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id pi2si7680248igb.60.2015.01.13.15.20.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 15:20:33 -0800 (PST)
Received: by mail-ig0-f176.google.com with SMTP id b16so4130461igk.3
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 15:20:33 -0800 (PST)
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org> <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for memory
In-reply-to: <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
Date: Tue, 13 Jan 2015 15:20:08 -0800
Message-ID: <xr93a91mz2s7.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org


On Thu, Jan 08 2015, Johannes Weiner wrote:

> Introduce the basic control files to account, partition, and limit
> memory using cgroups in default hierarchy mode.
>
> This interface versioning allows us to address fundamental design
> issues in the existing memory cgroup interface, further explained
> below.  The old interface will be maintained indefinitely, but a
> clearer model and improved workload performance should encourage
> existing users to switch over to the new one eventually.
>
> The control files are thus:
>
>   - memory.current shows the current consumption of the cgroup and its
>     descendants, in bytes.
>
>   - memory.low configures the lower end of the cgroup's expected
>     memory consumption range.  The kernel considers memory below that
>     boundary to be a reserve - the minimum that the workload needs in
>     order to make forward progress - and generally avoids reclaiming
>     it, unless there is an imminent risk of entering an OOM situation.

So this is try-hard, but no-promises interface.  No complaints.  But I
assume that an eventual extension is a more rigid memory.min which
specifies a minimum working set under which an container would prefer an
oom kill to thrashing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
