Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id AE4DF6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 11:42:17 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so22777685qgd.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 08:42:17 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com. [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id 144si2390507qhb.33.2015.05.07.08.42.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 08:42:17 -0700 (PDT)
Received: by qcyk17 with SMTP id k17so23130310qcy.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 08:42:16 -0700 (PDT)
Date: Thu, 7 May 2015 11:42:12 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] PM, freezer: Don't thaw when it's intended frozen
 processes
Message-ID: <20150507154212.GA12245@htj.duckdns.org>
References: <20150507064557.GA26928@july>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150507064557.GA26928@july>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-pm@vger.kernel.org

Hello,

On Thu, May 07, 2015 at 03:45:57PM +0900, Kyungmin Park wrote:
> From: Kyungmin Park <kyungmin.park@samsung.com>
> 
> Some platform uses freezer cgroup for speicial purpose to schedule out some applications. but after suspend & resume, these processes are thawed and running. 

They shouldn't be able to leave the freezer tho.  Resuming does wake
up all tasks but freezing() test would still evaulate to true for the
ones frozen by cgroup freezer and they will stay inside the freezer.

> but it's inteneded and don't need to thaw it.
> 
> To avoid it, does it possible to modify resume code and don't thaw it when resume? does it resonable?

I need to think more about it but as an *optimization* we can add
freezing() test before actually waking tasks up during resume, but can
you please clarify what you're seeing?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
