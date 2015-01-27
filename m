Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 37A846B0032
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 05:41:17 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id fb4so3770720wid.2
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 02:41:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x2si1393718wja.168.2015.01.27.02.41.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 02:41:15 -0800 (PST)
Date: Tue, 27 Jan 2015 11:41:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150127104112.GA19880@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
 <20150114165036.GI4706@dhcp22.suse.cz>
 <54B7F7C4.2070105@codeaurora.org>
 <20150116154922.GB4650@dhcp22.suse.cz>
 <54BA7D3A.40100@codeaurora.org>
 <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
 <20150126172832.GC22681@dhcp22.suse.cz>
 <20150126141159.cfb8357352e044f5d6f66369@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150126141159.cfb8357352e044f5d6f66369@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Mon 26-01-15 14:11:59, Andrew Morton wrote:
[...]
> So do we drop
> mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch?

I would like to see a confirmation from Vinayak that this really helped
in his test case first and only then drop the above patch. I really
think that we shouldn't spread hacks around the code just workaround
inefficiency in the vmstat code. We already have two places which need a
special treatment and who knows how many more will show up later.

Even with this patch applied we have other issues related to the
overloaded workqueues as mentioned earlier but those should be fixed by
a separate fixe(s).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
