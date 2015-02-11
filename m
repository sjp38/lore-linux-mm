Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id C6E596B006E
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:05:34 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id i57so2502190yha.12
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:05:34 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com. [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id t5si2543923qar.69.2015.02.11.14.05.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 14:05:34 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id f12so4957930qad.9
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:05:33 -0800 (PST)
Date: Wed, 11 Feb 2015 17:05:30 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150211220530.GA12728@htj.duckdns.org>
References: <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
 <20150206141746.GB10580@htj.dyndns.org>
 <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
 <20150207143839.GA9926@htj.dyndns.org>
 <20150211021906.GA21356@htj.duckdns.org>
 <CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
 <20150211203359.GF21356@htj.duckdns.org>
 <CALYGNiMm2VajBx0Y+XtLJ8860JS-GHfuSXQrBt32Wt0K7QpH0A@mail.gmail.com>
 <20150211214650.GA11920@htj.duckdns.org>
 <CALYGNiPX89HsgUS8BrJvL_jW-EU95xezc7uPf=0Pm72qiUwp7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPX89HsgUS8BrJvL_jW-EU95xezc7uPf=0Pm72qiUwp7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

On Thu, Feb 12, 2015 at 01:57:04AM +0400, Konstantin Khlebnikov wrote:
> On Thu, Feb 12, 2015 at 12:46 AM, Tejun Heo <tj@kernel.org> wrote:
> > Hello,
> >
> > On Thu, Feb 12, 2015 at 12:22:34AM +0300, Konstantin Khlebnikov wrote:
> >> > Yeah, available memory to the matching memcg and the number of dirty
> >> > pages in it.  It's gonna work the same way as the global case just
> >> > scoped to the cgroup.
> >>
> >> That might be a problem: all dirty pages accounted to cgroup must be
> >> reachable for its own personal writeback or balanace-drity-pages will be
> >> unable to satisfy memcg dirty memory thresholds. I've done accounting
> >
> > Yeah, it would.  Why wouldn't it?
> 
> How do you plan to do per-memcg/blkcg writeback for balance-dirty-pages?
> Or you're thinking only about separating writeback flow into blkio cgroups
> without actual inode filtering? I mean delaying inode writeback and keeping
> dirty pages as long as possible if their cgroups are far from threshold.

What?  The code was already in the previous patchset.  I'm just gonna
rip out the code to handle inode being dirtied on multiple wb's.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
