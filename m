Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8685E2806CB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 13:27:48 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f98so23232865iod.18
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 10:27:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l15si3342059pfk.415.2017.04.19.10.27.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 10:27:47 -0700 (PDT)
Date: Wed, 19 Apr 2017 10:27:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: acb32a95a9: BUG: kernel hang in test stage
Message-Id: <20170419102744.077ca9821540db6dc0f1b439@linux-foundation.org>
In-Reply-To: <20170419164602.GA4821@cmpxchg.org>
References: <58f78acc.kZ0tk19VlXn2CBsV%fengguang.wu@intel.com>
	<20170419164602.GA4821@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kernel test robot <fengguang.wu@intel.com>, mmotm auto import <mm-commits@vger.kernel.org>, LKP <lkp@01.org>, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com

On Wed, 19 Apr 2017 12:46:02 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Hi,
> 
> On Thu, Apr 20, 2017 at 12:05:32AM +0800, kernel test robot wrote:
> > Greetings,
> > 
> > 0day kernel testing robot got the below dmesg and the first bad commit is
> > 
> > git://git.cmpxchg.org/linux-mmotm.git master
> > 
> > commit acb32a95a90a6f88860eb344d04e1634ebbc2170
> > Author:     mmotm auto import <mm-commits@vger.kernel.org>
> > AuthorDate: Thu Apr 13 22:02:16 2017 +0000
> > Commit:     Johannes Weiner <hannes@cmpxchg.org>
> > CommitDate: Thu Apr 13 22:02:16 2017 +0000
> > 
> >     linux-next
> 
> Hm, you'd think the linux-next commit in the mm tree would produce
> problems more often, but this is the first time I've seen it as the
> culprit in a problem report.
> 
> Do problems usually get spotted inside linux-next.git first and then
> the same issues are not reported against the -mm tree?
> 
> I also just noticed that <mm-commits@vger.kernel.org> might be a bad
> author email since AFAIK it drops everything but akpm-mail.

yup, that's how davem originally set it up.  It's never caused a
problem but it's a bit odd and I guess we could ask hmi to change it.

> Andrew,
> would it be better to set you as the Author of these import patches?
> Easy enough to change my scripts.

Sure, that works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
