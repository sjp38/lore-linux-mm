Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F07446B025C
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:24:20 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id f206so300293489wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:24:20 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id kv9si2671120wjb.199.2016.01.13.07.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 07:24:19 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id l65so297991281wmf.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 07:24:19 -0800 (PST)
Date: Wed, 13 Jan 2016 16:24:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160113152416.GB17512@dhcp22.suse.cz>
References: <20160107145841.GN27868@dhcp22.suse.cz>
 <201601080038.CIF04698.VFJHSOQLOFFMOt@I-love.SAKURA.ne.jp>
 <20160111151835.GH27317@dhcp22.suse.cz>
 <201601122032.FHH13586.MOQVFFOJStFHOL@I-love.SAKURA.ne.jp>
 <20160112195200.GB4515@dhcp22.suse.cz>
 <201601131915.BCI35488.FHSFQtVMJOOOLF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601131915.BCI35488.FHSFQtVMJOOOLF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-01-16 19:15:58, Tetsuo Handa wrote:
[...]
> I like the OOM reaper approach. I said I don't like current patch because
> current patch ignores unlikely cases described below.

articulate your concerns regardning oom reaper in the email thread which
proposes it: e.g. here
http://lkml.kernel.org/r/1452094975-551-2-git-send-email-mhocko%40kernel.org

discussing it in an unrelated thread will not help future searching of
this topic.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
