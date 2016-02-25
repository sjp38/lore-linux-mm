Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id E466E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:25:49 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id hb3so23213099igb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:25:49 -0800 (PST)
Received: from out1134-233.mail.aliyun.com (out1134-233.mail.aliyun.com. [42.120.134.233])
        by mx.google.com with ESMTP id s84si12804203ioi.32.2016.02.25.14.25.48
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 14:25:49 -0800 (PST)
Message-ID: <56CF8043.1030603@emindsoft.com.cn>
Date: Fri, 26 Feb 2016 06:29:23 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net>
In-Reply-To: <20160225160707.GX2854@techsingularity.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 2/26/16 00:07, Mel Gorman wrote:
>>> On Thu, Feb 25, 2016 at 06:26:31AM +0800, chengang@emindsoft.com.cn wrote:
> 
> I do not want this patch to go through the trivial tree. It still adds
> another step to identifying relevant commits through git blame and has
> limited, if any, benefit to maintainability.
> 
>>   "it's preferable to preserve blame than go through a layer of cleanup
>>   when looking for the commit that defined particular flags".
>>
> 
> git blame identifies what commit last altered a line. If a cleanup patch
> is encountered then the tree before that commit needs to be examined
> which adds time. It's rare that cleanup patches on their own are useful
> and this is one of those cases.
> 

git is a tool mainly for analyzing code, but not mainly for normal
reading main code.

So for me, the coding styles need not consider about git.


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
