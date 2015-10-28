Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id EF4CA82F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 22:43:56 -0400 (EDT)
Received: by igbdj2 with SMTP id dj2so92816009igb.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 19:43:56 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id r6si19328473igh.49.2015.10.27.19.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 19:43:56 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so251818572pac.3
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 19:43:56 -0700 (PDT)
Date: Wed, 28 Oct 2015 11:43:50 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
Message-ID: <20151028024350.GA10448@mtj.duckdns.org>
References: <20151028024114.370693277@linux.com>
 <20151028024131.719968999@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151028024131.719968999@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Hello,

On Tue, Oct 27, 2015 at 09:41:17PM -0500, Christoph Lameter wrote:
> +	vmstat_wq = alloc_workqueue("vmstat",
> +		WQ_FREEZABLE|
> +		WQ_SYSFS|
> +		WQ_MEM_RECLAIM, 0);

The only thing necessary here is WQ_MEM_RECLAIM.  I don't see how
WQ_SYSFS and WQ_FREEZABLE make sense here.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
