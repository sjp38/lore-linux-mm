Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A64A6B0285
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 15:23:36 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id g18so122450ywb.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:23:36 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id v206si3057002ybv.113.2016.09.23.12.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 12:23:35 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id t67so6307803ywg.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:23:35 -0700 (PDT)
Date: Fri, 23 Sep 2016 15:23:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/1] mm/percpu.c: simplify grouping cpu logic in
 pcpu_build_alloc_info()
Message-ID: <20160923192334.GD31387@htj.duckdns.org>
References: <5dcf5870-67ad-97e4-518b-645d60b0a520@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5dcf5870-67ad-97e4-518b-645d60b0a520@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu@htc.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux.com

On Sat, Sep 24, 2016 at 02:15:09AM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> simplify grouping cpu logic in pcpu_build_alloc_info() to improve
> readability and performance, it discards the goto statement too
> 
> for every possible cpu, decide whether it can share group id of any
> lower index CPU, use the group id if so, otherwise a new group id
> is allocated to it
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>

I'm not gonna change that code unless there are clear upsides.  It's a
complicated code path which is run once during boot.  It's not worth
optimizing, the author doesn't explain how the change has been tested
or verified and doesn't respond to people pointing out that these
drive-by patches aren't helpful.

I won't engage with his patches until he changes his approach and
think that it's advisable for others to do so too.

Nacked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
