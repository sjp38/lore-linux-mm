Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E62D6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:29:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c202so36484103wme.10
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:29:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f5si9621947edd.72.2017.05.24.01.29.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 01:29:52 -0700 (PDT)
Date: Wed, 24 May 2017 10:29:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, we use rcu access task_struct in mm_match_cgroup(), but not
 use rcu free in free_task_struct()
Message-ID: <20170524082949.GB14733@dhcp22.suse.cz>
References: <5924E4A7.7000601@huawei.com>
 <59250EA3.60905@huawei.com>
 <263518b9-5a39-1af9-ac9e-055da3384aef@suse.cz>
 <59253E84.6010506@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59253E84.6010506@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "wencongyang (A)" <wencongyang2@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Dmitry Vyukov <dvyukov@google.com>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 24-05-17 16:04:20, Xishi Qiu wrote:
> On 2017/5/24 15:49, Vlastimil Babka wrote:
> 
> > On 05/24/2017 06:40 AM, Xishi Qiu wrote:
> >> On 2017/5/24 9:40, Xishi Qiu wrote:
> >>
> >>> Hi, I find we use rcu access task_struct in mm_match_cgroup(), but not use
> >>> rcu free in free_task_struct(), is it right?
> >>>
> >>> Here is the backtrace.
> > 
> > Can you post the whole oops, including kernel version etc? Is it the
> > same 3.10 RH kernel as in the other report?
> > 
> 
> Hi Vlastimil,
> 
> Yes, it's RHEL 7.2

Please contact Redhat for the support of this kernel. Feel free to
report the issue if it persists with the current vanilla kernel. It is
really hard for us to help you with a custom patched and an old kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
