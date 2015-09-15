Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id E2FB66B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:53:59 -0400 (EDT)
Received: by ykft14 with SMTP id t14so38201594ykf.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:53:59 -0700 (PDT)
Received: from mail-yk0-x236.google.com (mail-yk0-x236.google.com. [2607:f8b0:4002:c07::236])
        by mx.google.com with ESMTPS id f62si9417999ywa.28.2015.09.15.08.53.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 08:53:59 -0700 (PDT)
Received: by ykdu9 with SMTP id u9so190827017ykd.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 08:53:59 -0700 (PDT)
Date: Tue, 15 Sep 2015 11:53:55 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150915155355.GH2905@mtj.duckdns.org>
References: <20150913185940.GA25369@htj.duckdns.org>
 <20150913190008.GB25369@htj.duckdns.org>
 <20150915074724.GE2858@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915074724.GE2858@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello, Johannes.

On Tue, Sep 15, 2015 at 09:47:24AM +0200, Johannes Weiner wrote:
> Why can't we simply fail NOWAIT allocations when the high limit is
> breached? We do the same for the max limit.

Because that can lead to continued systematic failures of NOWAIT
allocations.  For that to work, we'll have to add async reclaimaing.

> As I see it, NOWAIT allocations are speculative attempts on available
> memory. We should be able to just fail them and have somebody that is
> allowed to reclaim try again, just like with the max limit.

Yes, but the assumption is that even back-to-back NOWAIT allocations
won't continue to fail indefinitely.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
