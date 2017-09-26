Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F07B06B0069
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:18:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r136so11276481wmf.4
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:18:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20si6904716wrb.482.2017.09.26.02.18.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 02:18:40 -0700 (PDT)
Date: Tue, 26 Sep 2017 11:18:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] a question about mlockall() and mprotect()
Message-ID: <20170926091837.fqvsurdvzapvlomu@dhcp22.suse.cz>
References: <59CA0847.8000508@huawei.com>
 <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz>
 <59CA125C.8000801@huawei.com>
 <20170926090255.jmocezs6s3lpd6p4@dhcp22.suse.cz>
 <59CA1A57.5000905@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59CA1A57.5000905@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

On Tue 26-09-17 17:13:59, Xishi Qiu wrote:
> On 2017/9/26 17:02, Michal Hocko wrote:
[...]
> > This is still very fuzzy. What are you actually trying to achieve?
> 
> I don't expect page fault any more after mlock.

This should be the case normally. Except when mm_populate fails which
can happen e.g. when running inside a memcg with the hard limit
configured. Is there any other unexpected failure scenario you are
seeing?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
