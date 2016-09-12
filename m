Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6F66B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 07:13:31 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k12so92059971lfb.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 04:13:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m8si4202923wjq.165.2016.09.12.04.13.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 04:13:29 -0700 (PDT)
Date: Mon, 12 Sep 2016 13:13:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
Message-ID: <20160912111327.GG14524@dhcp22.suse.cz>
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com>
 <20160909114410.GG4844@dhcp22.suse.cz>
 <57D67A8A.7070500@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57D67A8A.7070500@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On Mon 12-09-16 17:51:06, zhong jiang wrote:
[...]
> hi,  Michal
> oom reaper indeed can accelerate the recovery of memory, but the patch
> solve the extreme scenario, I hit it by runing trinity. I think the
> scenario can happen whether oom reaper or not.

could you be more specific about the case when the oom reaper and the
current oom code led to the oom deadlock?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
