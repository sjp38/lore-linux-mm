Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F40E28071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:28:12 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k11so29270223qtk.4
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:28:12 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id w13si9790768qtc.139.2017.05.19.13.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 13:28:11 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id u75so11629176qka.1
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:28:11 -0700 (PDT)
Date: Fri, 19 May 2017 16:28:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 08/17] cgroup: Move debug cgroup to its own file
Message-ID: <20170519202809.GB15279@wtj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-9-git-send-email-longman@redhat.com>
 <20170517213603.GE942@htj.duckdns.org>
 <ee36d4f8-9e9d-a5c7-2174-56c21aaf75af@redhat.com>
 <20170519192146.GA9741@wtj.duckdns.org>
 <8d942ee6-ebf4-5ba5-5484-60762808f544@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8d942ee6-ebf4-5ba5-5484-60762808f544@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello,

On Fri, May 19, 2017 at 03:33:14PM -0400, Waiman Long wrote:
> On 05/19/2017 03:21 PM, Tejun Heo wrote:
> > Yeah but it also shows up as an integral part of stable interface
> > rather than e.g. /sys/kernel/debug.  This isn't of any interest to
> > people who aren't developing cgroup core code.  There is no reason to
> > risk growing dependencies on it.
> 
> The debug controller is used to show information relevant to the cgroup
> its css'es are attached to. So it will be very hard to use if we
> relocate to /sys/kernel/debug, for example. Currently, nothing in the
> debug controller other than debug_cgrp_subsys are exported. I don't see
> any risk of having dependency on that controller from other parts of the
> kernel.

Oh, sure, I wasn't suggesting moving it under /sys/kernel/debug but
that we'd want to take extra precautions as we can't.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
