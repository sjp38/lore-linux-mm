Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46FB18E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 15:22:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so33907134edt.23
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 12:22:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h4si5123857eda.166.2019.01.03.12.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 12:22:38 -0800 (PST)
Date: Thu, 3 Jan 2019 21:22:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
Message-ID: <20190103202235.GE31793@dhcp22.suse.cz>
References: <20181220185031.43146-1-cai@lca.pw>
 <20181220203156.43441-1-cai@lca.pw>
 <20190103115114.GL31793@dhcp22.suse.cz>
 <e3ff1455-06cc-063e-24f0-3b525c345b84@lca.pw>
 <20190103165927.GU31793@dhcp22.suse.cz>
 <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
 <20190103190715.GZ31793@dhcp22.suse.cz>
 <62e96e34-7ea9-491a-b5b6-4828da980d48@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <62e96e34-7ea9-491a-b5b6-4828da980d48@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 14:53:47, Qian Cai wrote:
> On 1/3/19 2:07 PM, Michal Hocko wrote> So can we make the revert with an
> explanation that the patch was wrong?
> > If we want to make hacks to catch more objects to be tracked then it
> > would be great to have some numbers in hands.
> 
> Well, those numbers are subject to change depends on future start_kernel()
> order. Right now, there are many functions could be caught earlier by page owner.
> 
> 	kmemleak_init();
[...]
> 	sched_init_smp();

The kernel source dump will not tell us much of course. A ball park
number whether we are talking about dozen, hundreds or thousands of
allocations would tell us something at least, doesn't it.

Handwaving that it might help us some is not particurarly useful. We are
already losing some allocations already. Does it matter? Well, that
depends, sometimes we do want to catch an owner of particular page and
it is sad to find nothing. But how many times have you or somebody else
encountered that in practice. That is exactly a useful information to
judge an ugly ifdefery in the code. See my point?

-- 
Michal Hocko
SUSE Labs
