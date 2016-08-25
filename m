Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F35A96B0270
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:36:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so26079567lfe.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:36:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b73si13028753wmi.47.2016.08.25.00.36.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 00:36:49 -0700 (PDT)
Date: Thu, 25 Aug 2016 09:36:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [wrecked]
 mm-compaction-more-reliably-increase-direct-compaction-priority.patch
 removed from -mm tree
Message-ID: <20160825073646.GF4230@dhcp22.suse.cz>
References: <57bcb948./5Xz5gcuIQjtLmuG%akpm@linux-foundation.org>
 <20160824070859.GC31179@dhcp22.suse.cz>
 <20160824141418.b266d5a0bddf9170181f8627@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160824141418.b266d5a0bddf9170181f8627@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vbabka@suse.cz, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, riel@redhat.com, rientjes@google.com, linux-mm@kvack.org

On Wed 24-08-16 14:14:18, Andrew Morton wrote:
> On Wed, 24 Aug 2016 09:08:59 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Hi Andrew,
> > I guess the reason this patch has been dropped is due to
> > mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch.
> 
> Yes.  And I think we're still waiting testing feedback from the
> reporters on
> mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch?

yes
 
> > I guess we will wait for the above patch to get to Linus, revert it in mmotm
> > and re-apply
> > mm-compaction-more-reliably-increase-direct-compaction-priority.patch
> > again, right?
> 
> I suppose so.  We can leave
> mm-oom-prevent-pre-mature-oom-killer-invocation-for-high-order-request.patch
> in place in mainline for 4.8 so it can be respectably backported into
> -stable.
> 
> And we may as well fold
> mm-compaction-more-reliably-increase-direct-compaction-priority.patch
> into the patch which re-adds should_compact_retry()?

I am not sure combining those two into a single patch would be better.
It is true it would be bisect safe but those patches are not really
related because there are other changes for the compaction improvements
which already made a difference. This one is merely yet-another-change
on top. Let me think about that, though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
