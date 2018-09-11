Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 326BF8E0002
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 08:47:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z30-v6so8616189edd.19
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 05:47:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i31-v6si7072713edd.265.2018.09.11.05.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 05:47:39 -0700 (PDT)
Date: Tue, 11 Sep 2018 14:47:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Message-ID: <20180911124737.GV10951@dhcp22.suse.cz>
References: <20180910215622.4428-1-guro@fb.com>
 <20180911121141.GS10951@dhcp22.suse.cz>
 <0ea4cdbd-dc3f-1b66-8a5f-8d67ab0e2bc9@sony.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ea4cdbd-dc3f-1b66-8a5f-8d67ab0e2bc9@sony.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 11-09-18 14:41:04, peter enderborg wrote:
> On 09/11/2018 02:11 PM, Michal Hocko wrote:
> > Why is this a problem though? IIRC this event was deliberately placed
> > outside of the oom path because we wanted to count allocation failures
> > and this is also documented that way
> >
> >           oom
> >                 The number of time the cgroup's memory usage was
> >                 reached the limit and allocation was about to fail.
> >
> >                 Depending on context result could be invocation of OOM
> >                 killer and retrying allocation or failing a
> >
> > One could argue that we do not apply the same logic to GFP_NOWAIT
> > requests but in general I would like to see a good reason to change
> > the behavior and if it is really the right thing to do then we need to
> > update the documentation as well.
> >
> 
> Why not introduce a MEMCG_ALLOC_FAIL in to memcg_memory_event?

My understanding is that this is what the oom event is about.

-- 
Michal Hocko
SUSE Labs
