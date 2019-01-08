Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D42F8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 20:53:11 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id z6so2064893qtj.21
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 17:53:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c16sor62692559qtq.58.2019.01.07.17.53.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 17:53:10 -0800 (PST)
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
References: <20190103190715.GZ31793@dhcp22.suse.cz>
 <62e96e34-7ea9-491a-b5b6-4828da980d48@lca.pw>
 <20190103202235.GE31793@dhcp22.suse.cz>
 <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
 <20190104130906.GO31793@dhcp22.suse.cz>
 <e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
 <20190104151737.GT31793@dhcp22.suse.cz>
 <c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
 <20190104153245.GV31793@dhcp22.suse.cz>
 <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
 <20190107184309.GM31793@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
Date: Mon, 7 Jan 2019 20:53:08 -0500
MIME-Version: 1.0
In-Reply-To: <20190107184309.GM31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/7/19 1:43 PM, Michal Hocko wrote:
> On Fri 04-01-19 15:18:08, Qian Cai wrote:
> [...]
>> Though, I can't see any really benefit of this approach apart from "beautify"
> 
> This is not about beautifying! This is about making the code long term
> maintainable. As you can see it is just too easy to break it with the
> current scheme. And that is bad especially when the code is broken
> because of an optimization.
> 

Understood, but the code is now fixed. If there is something fundamentally
broken in the future, it may be a good time then to create a looks like
hundred-line cleanup patch for long-term maintenance at the same time to fix
real bugs.
