Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 02D4D6B0269
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:29:07 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o16-v6so971136pgv.21
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:29:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t67-v6si1651739pfd.364.2018.08.02.04.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:29:06 -0700 (PDT)
Date: Thu, 2 Aug 2018 13:29:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
Message-ID: <20180802112901.GH10808@dhcp22.suse.cz>
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
 <1532683495-31974-3-git-send-email-wei.w.wang@intel.com>
 <20180730090041.GC24267@dhcp22.suse.cz>
 <5B619599.1000307@intel.com>
 <20180801113444.GK16767@dhcp22.suse.cz>
 <5B62DDCC.3030100@intel.com>
 <87d7ae45-79cb-e294-7397-0e45e2af49cd@I-love.SAKURA.ne.jp>
 <5B62EAAC.8000505@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B62EAAC.8000505@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On Thu 02-08-18 19:27:40, Wei Wang wrote:
> On 08/02/2018 07:00 PM, Tetsuo Handa wrote:
> > On 2018/08/02 19:32, Wei Wang wrote:
> > > On 08/01/2018 07:34 PM, Michal Hocko wrote:
> > > > Do you have any numbers for how does this work in practice?
> > > It works in this way: for example, we can set the parameter, balloon_pages_to_shrink,
> > > to shrink 1GB memory once shrink scan is called. Now, we have a 8GB guest, and we balloon
> > > out 7GB. When shrink scan is called, the balloon driver will get back 1GB memory and give
> > > them back to mm, then the ballooned memory becomes 6GB.
> > Since shrinker might be called concurrently (am I correct?),
> 
> Not sure about it being concurrently, but I think it would be called
> repeatedly as should_continue_reclaim() returns true.

Multiple direct reclaimers might indeed invoke it concurrently.
-- 
Michal Hocko
SUSE Labs
