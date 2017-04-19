Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED31C6B0038
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 13:40:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m68so749176wmg.4
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 10:40:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y6si4688508wrb.0.2017.04.19.10.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 10:40:03 -0700 (PDT)
Date: Wed, 19 Apr 2017 13:39:53 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: acb32a95a9: BUG: kernel hang in test stage
Message-ID: <20170419173953.GA5517@cmpxchg.org>
References: <58f78acc.kZ0tk19VlXn2CBsV%fengguang.wu@intel.com>
 <20170419164602.GA4821@cmpxchg.org>
 <20170419102744.077ca9821540db6dc0f1b439@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419102744.077ca9821540db6dc0f1b439@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel test robot <fengguang.wu@intel.com>, mmotm auto import <mm-commits@vger.kernel.org>, LKP <lkp@01.org>, Linux Memory Management List <linux-mm@kvack.org>, wfg@linux.intel.com

On Wed, Apr 19, 2017 at 10:27:44AM -0700, Andrew Morton wrote:
> On Wed, 19 Apr 2017 12:46:02 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Hi,
> > 
> > On Thu, Apr 20, 2017 at 12:05:32AM +0800, kernel test robot wrote:
> > > Greetings,
> > > 
> > > 0day kernel testing robot got the below dmesg and the first bad commit is
> > > 
> > > git://git.cmpxchg.org/linux-mmotm.git master
> > > 
> > > commit acb32a95a90a6f88860eb344d04e1634ebbc2170
> > > Author:     mmotm auto import <mm-commits@vger.kernel.org>
> > > AuthorDate: Thu Apr 13 22:02:16 2017 +0000
> > > Commit:     Johannes Weiner <hannes@cmpxchg.org>
> > > CommitDate: Thu Apr 13 22:02:16 2017 +0000
> > > 
> > >     linux-next
> > 
> > Hm, you'd think the linux-next commit in the mm tree would produce
> > problems more often, but this is the first time I've seen it as the
> > culprit in a problem report.
> > 
> > Do problems usually get spotted inside linux-next.git first and then
> > the same issues are not reported against the -mm tree?
> > 
> > I also just noticed that <mm-commits@vger.kernel.org> might be a bad
> > author email since AFAIK it drops everything but akpm-mail.
> 
> yup, that's how davem originally set it up.  It's never caused a
> problem but it's a bit odd and I guess we could ask hmi to change it.
> 
> > Andrew,
> > would it be better to set you as the Author of these import patches?
> > Easy enough to change my scripts.
> 
> Sure, that works.

Okay, fixed.

http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=9cffa970e59a20315c8b73944dd93e37d2ecd785
vs.
http://git.cmpxchg.org/cgit.cgi/linux-mmots.git/commit/?id=c31d75472e61d0de0d9490bebd6d7167ae2eb5d6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
