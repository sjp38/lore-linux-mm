Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92E776B0038
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 12:46:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m68so680861wmg.4
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:46:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k25si4438680wre.305.2017.04.19.09.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 09:46:13 -0700 (PDT)
Date: Wed, 19 Apr 2017 12:46:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: acb32a95a9: BUG: kernel hang in test stage
Message-ID: <20170419164602.GA4821@cmpxchg.org>
References: <58f78acc.kZ0tk19VlXn2CBsV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58f78acc.kZ0tk19VlXn2CBsV%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <fengguang.wu@intel.com>
Cc: mmotm auto import <mm-commits@vger.kernel.org>, LKP <lkp@01.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com

Hi,

On Thu, Apr 20, 2017 at 12:05:32AM +0800, kernel test robot wrote:
> Greetings,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.cmpxchg.org/linux-mmotm.git master
> 
> commit acb32a95a90a6f88860eb344d04e1634ebbc2170
> Author:     mmotm auto import <mm-commits@vger.kernel.org>
> AuthorDate: Thu Apr 13 22:02:16 2017 +0000
> Commit:     Johannes Weiner <hannes@cmpxchg.org>
> CommitDate: Thu Apr 13 22:02:16 2017 +0000
> 
>     linux-next

Hm, you'd think the linux-next commit in the mm tree would produce
problems more often, but this is the first time I've seen it as the
culprit in a problem report.

Do problems usually get spotted inside linux-next.git first and then
the same issues are not reported against the -mm tree?

I also just noticed that <mm-commits@vger.kernel.org> might be a bad
author email since AFAIK it drops everything but akpm-mail. Andrew,
would it be better to set you as the Author of these import patches?
Easy enough to change my scripts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
