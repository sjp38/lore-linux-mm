Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id BB0EA6B0070
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 10:31:53 -0500 (EST)
Received: by igbhn18 with SMTP id hn18so37610720igb.2
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:31:53 -0800 (PST)
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com. [209.85.213.173])
        by mx.google.com with ESMTPS id f84si2022137ioj.14.2015.03.04.07.31.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 07:31:52 -0800 (PST)
Received: by igal13 with SMTP id l13so37666520iga.0
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:31:52 -0800 (PST)
Message-ID: <54F72567.3060406@kernel.dk>
Date: Wed, 04 Mar 2015 08:31:51 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH block/for-4.0-fixes] writeback: add missing INITIAL_JIFFIES
 init in global_update_bandwidth()
References: <20150304152243.GG3122@htj.duckdns.org> <20150304153050.GA1249@quack.suse.cz>
In-Reply-To: <20150304153050.GA1249@quack.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 03/04/2015 08:30 AM, Jan Kara wrote:
> On Wed 04-03-15 10:22:43, Tejun Heo wrote:
>> global_update_bandwidth() uses static variable update_time as the
>> timestamp for the last update but forgets to initialize it to
>> INITIALIZE_JIFFIES.
>>
>> This means that global_dirty_limit will be 5 mins into the future on
>> 32bit and some large amount jiffies into the past on 64bit.  This
>> isn't critical as the only effect is that global_dirty_limit won't be
>> updated for the first 5 mins after booting on 32bit machines,
>> especially given the auxiliary nature of global_dirty_limit's role -
>> protecting against global dirty threshold's sudden dips; however, it
>> does lead to unintended suboptimal behavior.  Fix it.
>    Looks good. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>

We should add that it fixes c42843f2f0bbc (from 2011!) as well.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
