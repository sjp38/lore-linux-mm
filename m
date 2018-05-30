Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 422356B02A8
	for <linux-mm@kvack.org>; Wed, 30 May 2018 06:46:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n9-v6so10820376wmh.6
        for <linux-mm@kvack.org>; Wed, 30 May 2018 03:46:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5-v6si1883114edq.426.2018.05.30.03.46.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 03:46:39 -0700 (PDT)
Date: Wed, 30 May 2018 12:46:37 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180530104637.GC27180@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
 <20180528083451.GE1517@dhcp22.suse.cz>
 <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
 <20180528132410.GD27180@dhcp22.suse.cz>
 <201805290605.DGF87549.LOVFMFJQSOHtFO@I-love.SAKURA.ne.jp>
 <1126233373.5118805.1527600426174.JavaMail.zimbra@redhat.com>
 <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp>
 <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>

On Wed 30-05-18 05:35:37, Chunyu Hu wrote:
[...]
> I'm trying to reuse the make_it_fail field in task for fault injection. As adding
> an extra memory alloc flag is not thought so good,  I think adding task flag
> is either? 

Yeah, task flag will be reduced to KMEMLEAK enabled configurations
without an additional maint. overhead. Anyway, you should really think
about how to guarantee trackability for atomic allocation requests. You
cannot simply assume that GFP_NOWAIT will succeed. I guess you really
want to have a pre-populated pool of objects for those requests. The
obvious question is how to balance such a pool. It ain't easy to track
memory by allocating more memory...

-- 
Michal Hocko
SUSE Labs
