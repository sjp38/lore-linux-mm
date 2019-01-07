Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE6C8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 13:43:14 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so606210plt.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 10:43:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h88si6943457pfa.49.2019.01.07.10.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 10:43:12 -0800 (PST)
Date: Mon, 7 Jan 2019 19:43:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
Message-ID: <20190107184309.GM31793@dhcp22.suse.cz>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 04-01-19 15:18:08, Qian Cai wrote:
[...]
> Though, I can't see any really benefit of this approach apart from "beautify"

This is not about beautifying! This is about making the code long term
maintainable. As you can see it is just too easy to break it with the
current scheme. And that is bad especially when the code is broken
because of an optimization.

-- 
Michal Hocko
SUSE Labs
