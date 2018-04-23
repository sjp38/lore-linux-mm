Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1135B6B0007
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:42:15 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f23-v6so14247957wra.20
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:42:15 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x1si4532908edc.117.2018.04.23.05.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 05:42:13 -0700 (PDT)
Date: Mon, 23 Apr 2018 13:41:51 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 2/2] mm: move the high field from struct mem_cgroup to
 page_counter
Message-ID: <20180423124145.GA29016@castle.DHCP.thefacebook.com>
References: <20180420163632.3978-1-guro@fb.com>
 <20180420163632.3978-2-guro@fb.com>
 <20180420205450.GB24563@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180420205450.GB24563@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Fri, Apr 20, 2018 at 04:54:50PM -0400, Johannes Weiner wrote:
> On Fri, Apr 20, 2018 at 05:36:32PM +0100, Roman Gushchin wrote:
> > We do store memory.min, memory.low and memory.max actual values
> > in struct page_counter fields, while memory.high value is located
> > in the struct mem_cgroup directly, which is not very consistent.
> > 
> > This patch moves the high field from struct mem_cgroup to
> > struct page_counter to simplify the code and make handling
> > of all limits/boundaries clearer.
> 
> I would prefer not doing this.
> 
> Yes, it looks a bit neater if all these things are next to each other
> in the struct, but on the other hand it separates the high variable
> from high_work, and it adds an unnecessary setter function as well.
> 
> Plus, nothing in the page_counter code actually uses the value, it
> really isn't part of that abstraction layer.
> 

Ok, not a problem.
It's nice to have all 4 limits in one place, but separating
high and high_work isn't good, I agree. Let's leave it as it is.

Thanks!
