Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 029A782F64
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:37:30 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so115129252pab.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:37:29 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id xg6si28611092pbc.62.2015.10.23.03.37.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 03:37:29 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so120692185pac.3
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 03:37:29 -0700 (PDT)
Date: Fri, 23 Oct 2015 19:37:20 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for
 zone_reclaimable()checks
Message-ID: <20151023103720.GB4170@mtj.duckdns.org>
References: <20151022151528.GG30579@mtj.duckdns.org>
 <20151022153559.GF26854@dhcp22.suse.cz>
 <20151022153703.GA3899@mtj.duckdns.org>
 <20151022154922.GG26854@dhcp22.suse.cz>
 <20151022184226.GA19289@mtj.duckdns.org>
 <201510230642.HDF57807.QJtSOVFFOMLHOF@I-love.SAKURA.ne.jp>
 <20151023083612.GC2410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151023083612.GC2410@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Fri, Oct 23, 2015 at 10:36:12AM +0200, Michal Hocko wrote:
> If WQ_MEM_RECLAIM can really guarantee one worker as described in the
> documentation then I agree that fixing vmstat is a better fix. But that
> doesn't seem to be the case currently.

It does.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
