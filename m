Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6516D6B0298
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 09:36:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id r2so5349015wra.4
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 06:36:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r17si1463505edl.492.2017.11.22.06.36.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 06:36:37 -0800 (PST)
Date: Wed, 22 Nov 2017 15:36:35 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-ID: <20171122143635.agyx5ceflalysjlb@dhcp22.suse.cz>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
 <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
 <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
 <20171122124551.tjxt7td5fmfqifnc@dhcp22.suse.cz>
 <201711222206.JGF73535.OFFQSLOJFtHMVO@I-love.SAKURA.ne.jp>
 <b04f6093-3b22-e57f-a276-bfaaf3b0ba1e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b04f6093-3b22-e57f-a276-bfaaf3b0ba1e@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, david@fromorbit.com, viro@zeniv.linux.org.uk, jack@suse.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On Wed 22-11-17 15:31:14, Paolo Bonzini wrote:
> On 22/11/2017 14:06, Tetsuo Handa wrote:
> >> I am not sure we want to overcomplicate the code too much. Most
> >> architectures do not have that many numa nodes to care. If we really
> >> need to care maybe we should rethink and get rid of the per numa
> >> deferred count altogether.
> > the amount of changes needed for checking for an error will exceed the amount of
> > changes needed for making register_shrinker() not to return an error.
> > Do we want to overcomplicate register_shrinker() callers?
> 
> For KVM it's not a big deal, fixing kvm_mmu_module_init to check the
> return value is trivial.

I suspect others will be in a similar situation. I've tried to do so for
sget_userns [1] and it didn't look terrible either.

[1] http://lkml.kernel.org/r/20171121140500.bgkpwcdk2dxesao4@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
