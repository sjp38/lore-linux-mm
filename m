Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54E25440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 07:25:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b9so840989wmh.5
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 04:25:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p61si2362636edd.543.2017.11.09.04.25.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 04:25:23 -0800 (PST)
Date: Thu, 9 Nov 2017 13:25:19 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/5] mm,page_alloc: Update comment for last second
 allocation attempt.
Message-ID: <20171109122519.gzopklggx3s222d6@dhcp22.suse.cz>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171108145039.tdueguedqos4rpk5@dhcp22.suse.cz>
 <201711091945.IAD64050.MtLFFQOOSOFJHV@I-love.SAKURA.ne.jp>
 <20171109113040.77gapoevxszejyfm@dhcp22.suse.cz>
 <201711092119.BJH69746.OFMOQFOLVtSFHJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711092119.BJH69746.OFMOQFOLVtSFHJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, hannes@cmpxchg.org

On Thu 09-11-17 21:19:24, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > So, I believe that the changelog is not wrong, and I don't want to preserve
> > > 
> > >   keep very high watermark here, this is only to catch a parallel oom killing,
> > >   we must fail if we're still under heavy pressure
> > > 
> > > part which lost strong background.
> > 
> > I do not see how. You simply do not address the original concern Andrea
> > had and keep repeating unrelated stuff.
> 
> What does "address the original concern Andrea had" mean?
> I'm still thinking that the original concern Andrea had is no longer
> valid in the current code because precondition has changed.

I am sorry but I am not going to repeat myself.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
