Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B25F8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 17:13:44 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id k66so4533193qkf.1
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 14:13:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f19sor65400177qtp.31.2019.01.08.14.13.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 14:13:43 -0800 (PST)
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
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
 <20190108082032.GP31793@dhcp22.suse.cz> <1546953547.6911.1.camel@lca.pw>
 <20190108140253.5b6db0ab37334b845e9d4fc2@linux-foundation.org>
From: Qian Cai <cai@lca.pw>
Message-ID: <c7a80f25-c30b-01cc-d2ef-49834f2d6078@lca.pw>
Date: Tue, 8 Jan 2019 17:13:41 -0500
MIME-Version: 1.0
In-Reply-To: <20190108140253.5b6db0ab37334b845e9d4fc2@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/8/19 5:02 PM, Andrew Morton wrote:
> 
> It's unclear (to me) where we stand with this patch.  Shold we proceed
> with v3 for now, or is something else planned?

I don't have anything else plan for this right now. Michal particular don't like
that 4-line ifdef which supposes to avoid an immediately regression (arguably
small) that existing page_owner users with DEFERRED_STRUCT_PAGE_INIT deselected
that would start to miss tens of thousands early page allocation call sites. So,
feel free to choose v2 of this which has no ifdef if you agree with Michal too.
I am fine either way.
