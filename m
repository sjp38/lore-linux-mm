Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id AEE2C6B0255
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 07:25:16 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so7915957pac.3
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 04:25:16 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id sa8si32337522pbb.131.2015.11.17.04.25.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 04:25:15 -0800 (PST)
Received: by padhk6 with SMTP id hk6so1127576pad.2
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 04:25:15 -0800 (PST)
Subject: Re: [PATCH v2] percpu: remove PERCPU_ENOUGH_ROOM which is stale definition
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Jungseok Lee <jungseoklee85@gmail.com>
In-Reply-To: <20151116155506.GC18894@mtj.duckdns.org>
Date: Tue, 17 Nov 2015 21:25:10 +0900
Content-Transfer-Encoding: 7bit
Message-Id: <7ECE283C-7EC8-4E17-98C5-F4895F17A2DC@gmail.com>
References: <1446643567-2250-1-git-send-email-jungseoklee85@gmail.com> <20151116155506.GC18894@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, tony.luck@intel.com, fenghua.yu@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Nov 17, 2015, at 12:55 AM, Tejun Heo wrote:

Dear Tejun,

> On Wed, Nov 04, 2015 at 01:26:07PM +0000, Jungseok Lee wrote:
>> As pure cleanup, this patch removes PERCPU_ENOUGH_ROOM which is not
>> used any more. That is, no code refers to the definition.
>> 
>> Acked-by: Christoph Lameter <cl@linux.com>
>> Signed-off-by: Jungseok Lee <jungseoklee85@gmail.com>
> 
> Applied to percpu/for-4.5.

I don't know how to handle this one as not getting feedbacks from ia64
side. Thanks for taking caring of this one!

Best Regards
Jungseok Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
