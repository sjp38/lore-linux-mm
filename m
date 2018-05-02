Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 288F36B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 08:53:14 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u56-v6so9766076wrf.18
        for <linux-mm@kvack.org>; Wed, 02 May 2018 05:53:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x4-v6si859639edq.436.2018.05.02.05.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 05:53:13 -0700 (PDT)
Date: Wed, 2 May 2018 13:52:39 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2] mm: introduce memory.min
Message-ID: <20180502125234.GA4025@castle.DHCP.thefacebook.com>
References: <20180423123610.27988-1-guro@fb.com>
 <20180502123040.GA16060@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180502123040.GA16060@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Wed, May 02, 2018 at 08:30:40AM -0400, Johannes Weiner wrote:
> On Mon, Apr 23, 2018 at 01:36:10PM +0100, Roman Gushchin wrote:
> > @@ -59,6 +59,12 @@ enum memcg_memory_event {
> >  	MEMCG_NR_MEMORY_EVENTS,
> >  };
> >  
> > +enum mem_cgroup_protection {
> > +	MEMCG_PROT_NONE,
> > +	MEMCG_PROT_LOW,
> > +	MEMCG_PROT_HIGH,
> 
> Ha, HIGH doesn't make much sense, but I went back and it's indeed what
> I suggested. Must have been a brainfart. This should be
> 
> MEMCG_PROT_NONE,
> MEMCG_PROT_LOW,
> MEMCG_PROT_MIN
> 
> right? To indicate which type of protection is applying.

Hm, I wasn't actually sure if it was a typo or not :)

But I thought that MEMCG_PROT_HIGH means a higher level
of protection than MEMCG_PROT_LOW, which sounds reasonable.

So, I'm fine with either option.

> 
> The rest of the patch looks good:
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 

Thanks!

Can you, also, please, take a look at this one:
https://lkml.org/lkml/2018/4/24/703.

Thank you!
