Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53BD86B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:29:20 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k71so1066189wrc.15
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:29:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l68si7360427wrc.508.2017.08.15.05.29.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 05:29:19 -0700 (PDT)
Date: Tue, 15 Aug 2017 14:29:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] mm, oom: fix oom_reaper fallouts
Message-ID: <20170815122915.GF29067@dhcp22.suse.cz>
References: <20170807113839.16695-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170807113839.16695-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Argangeli <andrea@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 07-08-17 13:38:37, Michal Hocko wrote:
> Hi,
> there are two issues this patch series attempts to fix. First one is
> something that has been broken since MMF_UNSTABLE flag introduction
> and I guess we should backport it stable trees (patch 1). The other
> issue has been brought up by Wenwei Tao and Tetsuo Handa has created
> a test case to trigger it very reliably. I am not yet sure this is a
> stable material because the test case is rather artificial. If there is
> a demand for the stable backport I will prepare it, of course, though.
> 
> I hope I've done the second patch correctly but I would definitely
> appreciate some more eyes on it. Hence CCing Andrea and Kirill. My
> previous attempt with some more context was posted here
> http://lkml.kernel.org/r/20170803135902.31977-1-mhocko@kernel.org
> 
> My testing didn't show anything unusual with these two applied on top of
> the mmotm tree.

unless anybody object can we have this merged? Whether to push this to
the stable tree is still questionable because it requires a rather
artificial workload to trigger the issue but if others think it would be
better to have it backported I will prepare backports for all relevant
stable trees.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
