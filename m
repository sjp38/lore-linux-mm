Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40ABF6B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 09:58:14 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x43so13286355wrb.9
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 06:58:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f127si2853826wmf.87.2017.08.17.06.58.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Aug 2017 06:58:12 -0700 (PDT)
Date: Thu, 17 Aug 2017 15:58:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Re: Re: [PATCH 2/2] mm, oom: fix potential data corruption
 when oom_reaper races with writer
Message-ID: <20170817135810.GB17786@dhcp22.suse.cz>
References: <201708151006.v7FA6SxD079619@www262.sakura.ne.jp>
 <20170815122621.GE29067@dhcp22.suse.cz>
 <201708151258.v7FCwTsV029946@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708151258.v7FCwTsV029946@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 15-08-17 21:58:29, Tetsuo Handa wrote:
[...]
> If I apply this patch, I can no longer reproduce this problem even with btrfs.
> 
> -+ * and could cause a memory corruption (zero pages instead of the
> -+ * original content).
> ++ * and could cause a memory corruption (random content instead of the
> ++ * original content).

If anything then I would word it this way

and could cause a memory corruption (zero pages for refaults but even a
random content has been observed but never explained properly)

> Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
