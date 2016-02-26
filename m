Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7D96B0257
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:03:22 -0500 (EST)
Received: by mail-io0-f179.google.com with SMTP id z135so125290362iof.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:03:22 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id cq8si5016679igb.27.2016.02.26.07.03.19
        for <linux-mm@kvack.org>;
        Fri, 26 Feb 2016 07:03:20 -0800 (PST)
Message-ID: <56D06A01.3080207@emindsoft.com.cn>
Date: Fri, 26 Feb 2016 23:06:41 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn> <alpine.DEB.2.10.1602260806380.16296@hxeon>
In-Reply-To: <alpine.DEB.2.10.1602260806380.16296@hxeon>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 2/26/16 07:12, SeongJae Park wrote:
> 
> On Fri, 26 Feb 2016, Chen Gang wrote:
> 
>>
>> git is a tool mainly for analyzing code, but not mainly for normal
>> reading main code.
>>
>> So for me, the coding styles need not consider about git.
> 
> 
> It is common to see reject of trivial coding style fixup patch here and
> there.  Those patches usually be merged for early stage files that only
> few people read / write.  However, for files that are old and lots of
> people read and write, those patches are rejected in usual.  I mean, the
> negative opinions for this patches are usual in this community.
> 
> I agree that coding style is important and respect your effort.  However,
> because the code will be seen and written by most kernel hackers, the file
> should be maintained to be easily readable and writable by most kernel
> hackers, especially, maintainers.  What I want to say is, we should
> respect maintainers' opinion in usual.
> 

Yes we need consider about the maintainers' options.

And my another ideas are replied in the other thread, please check, and
welcome any ideas, suggestion, and completions.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
