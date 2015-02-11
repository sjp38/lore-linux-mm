Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id A02746B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 15:34:03 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id s11so5119142qcv.11
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:34:03 -0800 (PST)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id x46si2189377qgx.121.2015.02.11.12.34.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 12:34:02 -0800 (PST)
Received: by mail-qg0-f42.google.com with SMTP id z107so4738438qgd.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 12:34:02 -0800 (PST)
Date: Wed, 11 Feb 2015 15:33:59 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150211203359.GF21356@htj.duckdns.org>
References: <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com>
 <20150205131514.GD25736@htj.dyndns.org>
 <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
 <20150205222522.GA10580@htj.dyndns.org>
 <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
 <20150206141746.GB10580@htj.dyndns.org>
 <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
 <20150207143839.GA9926@htj.dyndns.org>
 <20150211021906.GA21356@htj.duckdns.org>
 <CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

Hello, Greg.

On Wed, Feb 11, 2015 at 10:28:44AM -0800, Greg Thelen wrote:
> This seems good.  I assume that blkcg writeback would query
> corresponding memcg for dirty page count to determine if over
> background limit.  And balance_dirty_pages() would query memcg's dirty

Yeah, available memory to the matching memcg and the number of dirty
pages in it.  It's gonna work the same way as the global case just
scoped to the cgroup.

> page count to throttle based on blkcg's bandwidth.  Note: memcg
> doesn't yet have dirty page counts, but several of us have made
> attempts at adding the counters.  And it shouldn't be hard to get them
> merged.

Can you please post those?

So, cool, we're in agreement.  Working on it.  It shouldn't take too
long, hopefully.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
