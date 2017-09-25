Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2DC6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 10:23:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so9248040wra.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 07:23:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k13si5600577edl.288.2017.09.25.07.23.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 07:23:56 -0700 (PDT)
Date: Mon, 25 Sep 2017 16:23:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2 v4] oom: capture unreclaimable slab info in oom
 message when kernel panic
Message-ID: <20170925142352.havlx6ikheanqyhj@dhcp22.suse.cz>
References: <1505947132-4363-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505947132-4363-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 21-09-17 06:38:50, Yang Shi wrote:
> Recently we ran into a oom issue, kernel panic due to no killable process.
> The dmesg shows huge unreclaimable slabs used almost 100% memory, but kdump doesn't capture vmcore due to some reason.
> 
> So, it may sound better to capture unreclaimable slab info in oom message when kernel panic to aid trouble shooting and cover the corner case.
> Since kernel already panic, so capturing more information sounds worthy and doesn't bother normal oom killer.
> 
> With the patchset, tools/vm/slabinfo has a new option, "-U", to show unreclaimable slab only.
> 
> And, oom will print all non zero (num_objs * size != 0) unreclaimable slabs in oom killer message.

Well, I do undestand that this _might_ be useful but it also might
generates a _lot_ of output. The oom report can be quite verbose already
so is this something we want to have enabled by default?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
