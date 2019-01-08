Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 783AD8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 03:20:37 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c34so1273371edb.8
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 00:20:37 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si2016387edq.284.2019.01.08.00.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 00:20:36 -0800 (PST)
Date: Tue, 8 Jan 2019 09:20:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
Message-ID: <20190108082032.GP31793@dhcp22.suse.cz>
References: <20190103202235.GE31793@dhcp22.suse.cz>
 <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
 <20190104130906.GO31793@dhcp22.suse.cz>
 <e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
 <20190104151737.GT31793@dhcp22.suse.cz>
 <c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
 <20190104153245.GV31793@dhcp22.suse.cz>
 <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
 <20190107184309.GM31793@dhcp22.suse.cz>
 <bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 07-01-19 20:53:08, Qian Cai wrote:
> 
> 
> On 1/7/19 1:43 PM, Michal Hocko wrote:
> > On Fri 04-01-19 15:18:08, Qian Cai wrote:
> > [...]
> >> Though, I can't see any really benefit of this approach apart from "beautify"
> > 
> > This is not about beautifying! This is about making the code long term
> > maintainable. As you can see it is just too easy to break it with the
> > current scheme. And that is bad especially when the code is broken
> > because of an optimization.
> > 
> 
> Understood, but the code is now fixed. If there is something fundamentally
> broken in the future, it may be a good time then to create a looks like
> hundred-line cleanup patch for long-term maintenance at the same time to fix
> real bugs.

Yeah, so revert = fix and redisign the thing to make the code more
robust longterm + allow to catch more allocation. I really fail to see
why this has to be repeated several times in this thread. Really.

-- 
Michal Hocko
SUSE Labs
