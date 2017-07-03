Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 827626B02F4
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 11:33:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c81so19865063wmd.10
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 08:33:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x76si11222038wma.40.2017.07.03.08.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 08:33:16 -0700 (PDT)
Date: Mon, 3 Jul 2017 17:33:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH mm] introduce reverse buddy concept to reduce buddy
 fragment
Message-ID: <20170703153307.GA11848@dhcp22.suse.cz>
References: <1498821941-55771-1-git-send-email-zhouxianrong@huawei.com>
 <20170703074829.GD3217@dhcp22.suse.cz>
 <bfb807bf-92ce-27aa-d848-a6cab055447f@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bfb807bf-92ce-27aa-d848-a6cab055447f@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, alexander.h.duyck@intel.com, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, hannes@cmpxchg.org, minchan@kernel.org, npiggin@gmail.com, kirill.shutemov@linux.intel.com, gi-oh.kim@profitbricks.com, luto@kernel.org, keescook@chromium.org, mark.rutland@arm.com, mingo@kernel.org, heiko.carstens@de.ibm.com, iamjoonsoo.kim@lge.com, rientjes@google.com, ming.ling@spreadtrum.com, jack@suse.cz, ebru.akagunduz@gmail.com, bigeasy@linutronix.de, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, fanghua3@huawei.com, won.ho.park@huawei.com

On Mon 03-07-17 20:02:16, zhouxianrong wrote:
[...]
> from above i think after applying the patch the result is better.

You haven't described your testing methodology, nor the workload that was
tested. As such this data is completely meaningless.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
