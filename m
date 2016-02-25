Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 774586B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 09:08:51 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id j125so40698598oih.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:08:51 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id i64si6836550oib.83.2016.02.25.06.08.47
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 06:08:49 -0800 (PST)
Message-ID: <56CF0BB6.2040102@emindsoft.com.cn>
Date: Thu, 25 Feb 2016 22:12:06 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <alpine.DEB.2.10.1602250952030.16296@hxeon>
In-Reply-To: <alpine.DEB.2.10.1602250952030.16296@hxeon>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, mgorman@techsingularity.net, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org

On 2/25/16 09:01, SeongJae Park wrote:
> 
> Well, the indentation for the comment and the '\' looks odd to me.  If
> the 80 column limit is necessary, how about moving the comment to above
> line of the macro as below?  Because comments are usually placed before
> the target they are explaining, I believe this may better to read.
> 
>  -#define __GFP_MOVABLE        ((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
>  +/* ZONE_MOVABLE allowed */
>  +#define __GFP_MOVABLE        ((__force gfp_t)___GFP_MOVABLE)
> 
> Maybe the opinion can be applied to below similar changes, too.
> 

At least for me, what you said above is OK (it is a common way).

And welcome other members' suggestions.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
