Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5052C6B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 20:09:24 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so75494504pad.7
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 17:09:23 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id z3si21806409pas.111.2015.02.01.17.09.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 17:09:23 -0800 (PST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so75514203pad.1
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 17:09:23 -0800 (PST)
Date: Mon, 2 Feb 2015 10:09:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration when freeing
 size_class
Message-ID: <20150202010904.GA6402@blaptop>
References: <1422107403-10071-1-git-send-email-opensource.ganesh@gmail.com>
 <CADAEsF_fVRNCY-mx1EoyO2KwREfz6753JKdHpHMgbJUXf2sdsQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADAEsF_fVRNCY-mx1EoyO2KwREfz6753JKdHpHMgbJUXf2sdsQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello Ganesh,

On Sat, Jan 31, 2015 at 04:59:58PM +0800, Ganesh Mahendran wrote:
> ping.
> 
> 2015-01-24 21:50 GMT+08:00 Ganesh Mahendran <opensource.ganesh@gmail.com>:
> > The pool->size_class[i] is assigned with the i from (zs_size_classes - 1) to 0.
> > So if we failed in zs_create_pool(), we only need to iterate from (zs_size_classes - 1)
> > to i, instead of from 0 to (zs_size_classes - 1)
> 
> No functionality has been changed. This patch just avoids some
> necessary iteration.

Sorry for the delay. Did you saw any performance problem?
I know it would be better than old but your assumption depends on the
implmentation of zs_create_pool so if we changes(for example,
revert 9eec4cd if compaction works well), your patch would be void.
If it's not a critical, I'd like to remain it as generic and doesn't
contaminate git-blame.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
