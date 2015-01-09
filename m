Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 350556B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 16:46:53 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id f12so8874286qad.4
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 13:46:53 -0800 (PST)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id 39si13898199qgp.25.2015.01.09.13.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 13:46:52 -0800 (PST)
Received: by mail-qc0-f170.google.com with SMTP id x3so11220698qcv.1
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 13:46:51 -0800 (PST)
Date: Fri, 9 Jan 2015 16:46:49 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150109214649.GF2785@htj.dyndns.org>
References: <54B01335.4060901@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54B01335.4060901@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>

On Fri, Jan 09, 2015 at 05:43:17PM +0000, Suzuki K. Poulose wrote:
> We have hit a hang on ARM64 defconfig, while running LTP tests on 3.19-rc3.
> We are
> in the process of a git bisect and will update the results as and
> when we find the commit.
> 
> During the ksm ltp run, the test hangs trying to mount memcg with the
> following strace
> output:
> 
> mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") = ? ERESTARTNOINTR (To
> be restarted)
> mount("memcg", "/dev/cgroup", "cgroup", 0, "memory") = ? ERESTARTNOINTR (To
> be restarted)
> [ ... repeated forever ... ]
> 
> At this point, one can try mounting the memcg to verify the problem.
> # mount -t cgroup -o memory memcg memcg_dir
> --hangs--
> 
> Strangely, if we run the mount command from a cold boot (i.e. without
> running LTP first),
> then it succeeds.

I don't know what LTP is doing and this could actually be hitting on
an actual bug but if it's trying to move memcg back from unified
hierarchy to an old one, that might hang - it should prolly made to
just fail at that point.  Anyways, any chance you can find out what
happened, in terms of cgroup mounting, to memcg upto that point?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
