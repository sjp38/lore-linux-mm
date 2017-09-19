Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68BB66B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 14:57:50 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g128so690878qke.5
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 11:57:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a9sor9050qtg.52.2017.09.19.11.57.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 11:57:49 -0700 (PDT)
Date: Tue, 19 Sep 2017 11:57:45 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: do not back off draining pcp free
 pages from kworker context
Message-ID: <20170919185745.GB828415@devbig577.frc2.facebook.com>
References: <20170828093341.26341-1-mhocko@kernel.org>
 <20170828153359.f9b252f99647eebd339a3a89@linux-foundation.org>
 <6e138348-aa28-8660-d902-96efafe1dcb2@I-love.SAKURA.ne.jp>
 <20170829112823.GA12413@dhcp22.suse.cz>
 <20170831053342.fo7x4hnhicxikme4@dhcp22.suse.cz>
 <20170919033821.GR378890@devbig577.frc2.facebook.com>
 <20170919094521.2vqcnqrx3q2h2axb@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170919094521.2vqcnqrx3q2h2axb@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Tue, Sep 19, 2017 at 11:45:21AM +0200, Michal Hocko wrote:
> > So, this shouldn't be an issue.  This may get affected by direct
> > reclaim frenzy but it's only a small piece of the whole symptom and we
> > gotta fix that at the source.
> 
> OK, so there shouldn't be any issue with the patch, right?

idk, it'll make the code path more susceptible to direct reclaim
starvations, so it's difficult to claim that there won't be *any*
problems; however, given the extent of the starvation problem, this
likely won't add any noticeable issues.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
