Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 067C16B0007
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 01:39:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id s3-v6so3784635plp.21
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 22:39:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4-v6si7170335pgl.435.2018.07.05.22.39.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 22:39:03 -0700 (PDT)
Date: Fri, 6 Jul 2018 07:39:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <20180706053900.GE32658@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, kbuild test robot <fengguang.wu@intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 05-07-18 16:46:21, Andrew Morton wrote:
> On Thu, 21 Jun 2018 14:35:20 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> > it cannot reap an mm.  This can happen for a variety of reasons,
> > including:
> > 
> >  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> > 
> >  - when the mm has blockable mmu notifiers that could cause the oom reaper
> >    to stall indefinitely,
> > 
> > but we can also add a third when the oom reaper can "reap" an mm but doing
> > so is unlikely to free any amount of memory:
> > 
> >  - when the mm's memory is mostly mlocked.
> 
> Michal has been talking about making the oom-reaper handle mlocked
> memory.  Where are we at with that?

I didn't get to mlocked memory yet because blockable mmu notifiers are
more important. And I've already posted patch for that and it is under
discussion [1]. Mlocked memory is next. 
 
[1] http://lkml.kernel.org/r/20180627074421.GF32348@dhcp22.suse.cz

Btw. I still hate this patch and making any timeout user defineable. It
is a wrong approach and my nack to this patch still applies.

-- 
Michal Hocko
SUSE Labs
