Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 596E96B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:39:07 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id g62so47806797wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:39:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si12267203wjz.111.2016.02.25.14.39.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 14:39:06 -0800 (PST)
Date: Thu, 25 Feb 2016 23:39:04 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
In-Reply-To: <56CF8043.1030603@emindsoft.com.cn>
Message-ID: <alpine.LNX.2.00.1602252334400.22700@cbobk.fhfr.pm>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Mel Gorman <mgorman@techsingularity.net>, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

On Fri, 26 Feb 2016, Chen Gang wrote:

> > git blame identifies what commit last altered a line. If a cleanup patch
> > is encountered then the tree before that commit needs to be examined
> > which adds time. It's rare that cleanup patches on their own are useful
> > and this is one of those cases.
> 
> git is a tool mainly for analyzing code, but not mainly for normal
> reading main code.
> 
> So for me, the coding styles need not consider about git.

You are mistaken here. It's very helpful when debugging; usually you want 
to find the commit that introduced particular change, and read its 
changelog (at least). Having to cross rather pointless changes just adds 
time (need to restart git-blame with commit~1 as a base) for no really 
good reason.

Thanks,

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
