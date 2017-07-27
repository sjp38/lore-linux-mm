Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 935A46B04D7
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 18:23:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j79so223902890pfj.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:23:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t4si12237042plb.587.2017.07.27.15.23.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 15:23:40 -0700 (PDT)
Subject: Re: [4.13-rc1] /proc/meminfo reports that Slab: is little used.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201707260628.v6Q6SmaS030814@www262.sakura.ne.jp>
	<20170727162355.GA23896@cmpxchg.org>
In-Reply-To: <20170727162355.GA23896@cmpxchg.org>
Message-Id: <201707280723.ECG51112.JSFFLQOHtVOMFO@I-love.SAKURA.ne.jp>
Date: Fri, 28 Jul 2017 07:23:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: josef@toxicpanda.com, mhocko@suse.com, vdavydov.dev@gmail.com, riel@redhat.com, linux-mm@kvack.org

Johannes Weiner wrote:

> On Wed, Jul 26, 2017 at 03:28:48PM +0900, Tetsuo Handa wrote:
> > Commit 385386cff4c6f047 ("mm: vmstat: move slab statistics from zone to
> > node counters") broke "Slab:" field of /proc/meminfo . It shows nearly 0kB.
> 
> Thanks for the report. Can you confirm the below fixes the issue?

Yes, this fixed the issue.

Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
