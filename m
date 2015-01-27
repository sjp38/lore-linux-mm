Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 551A26B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 05:45:14 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so3769314wiw.4
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 02:45:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ft7si1415545wjb.169.2015.01.27.02.45.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 02:45:13 -0800 (PST)
Date: Tue, 27 Jan 2015 11:45:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150127104511.GB19880@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
 <20150114165036.GI4706@dhcp22.suse.cz>
 <54B7F7C4.2070105@codeaurora.org>
 <20150116154922.GB4650@dhcp22.suse.cz>
 <54BA7D3A.40100@codeaurora.org>
 <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
 <20150126172832.GC22681@dhcp22.suse.cz>
 <54C76995.70501@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54C76995.70501@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Tue 27-01-15 16:03:57, Vinayak Menon wrote:
[...]
> Sure, I can retest.

Thanks!

> Even without highly overloaded workqueues, there can be a delay of HZ in
> updating the counters. This means reclaim path can be blocked for a second
> or more, when there aren't really any isolated pages. So we need the fix in
> too_many_isolated also right ?

Is this a big deal though? What you are hitting is certainly a corner
case. I assume your system is trashing heavily already with so few pages
on the file LRU list.

Anyway as mentioned in other email I would rather see vmstat data more
reliable than spread hacks to the code where we see immediate issues.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
