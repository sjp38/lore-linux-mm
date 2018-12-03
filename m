Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2446B68EF
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:57:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so6483172edc.9
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:57:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z16-v6si3293412eju.332.2018.12.03.03.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 03:57:37 -0800 (PST)
Date: Mon, 3 Dec 2018 12:57:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm/memcg: Avoid reclaiming below hard protection
Message-ID: <20181203115736.GQ31738@dhcp22.suse.cz>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203080119.18989-3-xlpang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203080119.18989-3-xlpang@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 03-12-18 16:01:19, Xunlei Pang wrote:
> When memcgs get reclaimed after its usage exceeds min, some
> usages below the min may also be reclaimed in the current
> implementation, the amount is considerably large during kswapd
> reclaim according to my ftrace results.

And here again. Describe the setup and the behavior please?

-- 
Michal Hocko
SUSE Labs
