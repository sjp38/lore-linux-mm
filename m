Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 848848E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 17:40:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so2183675edd.2
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 14:40:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t26si542292eds.246.2019.01.08.14.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 14:40:31 -0800 (PST)
Date: Tue, 8 Jan 2019 23:40:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
Message-ID: <20190108224026.GL31793@dhcp22.suse.cz>
References: <20190104151737.GT31793@dhcp22.suse.cz>
 <c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
 <20190104153245.GV31793@dhcp22.suse.cz>
 <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
 <20190107184309.GM31793@dhcp22.suse.cz>
 <bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
 <20190108082032.GP31793@dhcp22.suse.cz>
 <1546953547.6911.1.camel@lca.pw>
 <20190108140253.5b6db0ab37334b845e9d4fc2@linux-foundation.org>
 <c7a80f25-c30b-01cc-d2ef-49834f2d6078@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c7a80f25-c30b-01cc-d2ef-49834f2d6078@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 08-01-19 17:13:41, Qian Cai wrote:
> 
> 
> On 1/8/19 5:02 PM, Andrew Morton wrote:
> > 
> > It's unclear (to me) where we stand with this patch.  Shold we proceed
> > with v3 for now, or is something else planned?
> 
> I don't have anything else plan for this right now. Michal particular don't like
> that 4-line ifdef which supposes to avoid an immediately regression (arguably
> small) that existing page_owner users with DEFERRED_STRUCT_PAGE_INIT deselected
> that would start to miss tens of thousands early page allocation call sites. So,
> feel free to choose v2 of this which has no ifdef if you agree with Michal too.
> I am fine either way.

Yes I would prefer to revert the faulty commit (fe53ca54270) and work on
a more robust page_owner initialization to cover earlier allocations on
top of that.

Not that I would insist but this would be a more straightforward
approach and I hope it will result in a better long term maintainable
code in the end.

-- 
Michal Hocko
SUSE Labs
