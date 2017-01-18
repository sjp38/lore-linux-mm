Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 912406B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 16:18:50 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id c7so4763220wjb.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:18:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y1si1715892wrc.161.2017.01.18.13.18.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 13:18:49 -0800 (PST)
Date: Wed, 18 Jan 2017 22:18:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-swap-add-cluster-lock-v5.patch added to -mm tree
Message-ID: <20170118211842.GE17135@dhcp22.suse.cz>
References: <587eaca3.MRSwND8OEi+lF+VH%akpm@linux-foundation.org>
 <20170118083731.GF7015@dhcp22.suse.cz>
 <20170118122354.9b06459e2588e53b537ca78c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118122354.9b06459e2588e53b537ca78c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ying.huang@intel.com, aarcange@redhat.com, aaron.lu@intel.com, ak@linux.intel.com, borntraeger@de.ibm.com, corbet@lwn.net, dave.hansen@intel.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, hughd@google.com, kirill.shutemov@linux.intel.com, minchan@kernel.org, riel@redhat.com, shli@kernel.org, tim.c.chen@linux.intel.com, vdavydov.dev@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Wed 18-01-17 12:23:54, Andrew Morton wrote:
> On Wed, 18 Jan 2017 09:37:31 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 17-01-17 15:45:39, Andrew Morton wrote:
> > [...]
> > > From: "Huang\, Ying" <ying.huang@intel.com>
> > > Subject: mm-swap-add-cluster-lock-v5
> > 
> > I assume you are going to fold this into the original patch. Do you
> > think it would make sense to have it in a separate patch along with
> > the reasoning provided via email?
> 
> It should be OK - the v5 changelog (which I shall use for the folded
> patch, as usual) has
> 
> : Compared with a previous implementation using bit_spin_lock, the
> : sequential swap out throughput improved about 3.2%.  Test was done on a
> : Xeon E5 v3 system.  The swap device used is a RAM simulated PMEM
> : (persistent memory) device.  To test the sequential swapping out, the test
> : case created 32 processes, which sequentially allocate and write to the
> : anonymous pages until the RAM and part of the swap device is used.

But there are more reasons than the throughput improvements. I would
consider the full lockdep support and fairness more important. The
drawback is the memory footprint which should be mentioned as well.

That being said, I will not insist, I just thought that this would be a
nice incremental change and easier to understand later rather than
searching the archives...

So take all this as my 2c...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
