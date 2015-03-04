Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7F45B6B0072
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 10:38:23 -0500 (EST)
Received: by igkb16 with SMTP id b16so37527742igk.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:38:23 -0800 (PST)
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com. [209.85.223.177])
        by mx.google.com with ESMTPS id ga12si15414158igd.34.2015.03.04.07.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 07:38:22 -0800 (PST)
Received: by iecrl12 with SMTP id rl12so68024035iec.4
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:38:22 -0800 (PST)
Message-ID: <54F726ED.4010801@kernel.dk>
Date: Wed, 04 Mar 2015 08:38:21 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH block/for-4.0-fixes] writeback: add missing INITIAL_JIFFIES
 init in global_update_bandwidth()
References: <20150304152243.GG3122@htj.duckdns.org> <20150304153050.GA1249@quack.suse.cz> <54F72567.3060406@kernel.dk> <20150304153743.GH3122@htj.duckdns.org>
In-Reply-To: <20150304153743.GH3122@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 03/04/2015 08:37 AM, Tejun Heo wrote:
> Subject: writeback: add missing INITIAL_JIFFIES init in global_update_bandwidth()
>
> global_update_bandwidth() uses static variable update_time as the
> timestamp for the last update but forgets to initialize it to
> INITIALIZE_JIFFIES.
>
> This means that global_dirty_limit will be 5 mins into the future on
> 32bit and some large amount jiffies into the past on 64bit.  This
> isn't critical as the only effect is that global_dirty_limit won't be
> updated for the first 5 mins after booting on 32bit machines,
> especially given the auxiliary nature of global_dirty_limit's role -
> protecting against global dirty threshold's sudden dips; however, it
> does lead to unintended suboptimal behavior.  Fix it.
>
> Fixes: c42843f2f0bb ("writeback: introduce smoothed global dirty limit")
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Acked-by: Jan Kara <jack@suse.cz>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: stable@vger.kernel.org
> ---
> Added the "fixes" tag.  Jens, can you please route this one?

Yup will do, thanks Tejun.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
