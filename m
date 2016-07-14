Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3F96B0261
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:26:38 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id q2so150967777pap.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:26:38 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id pi3si4671529pac.93.2016.07.14.13.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 13:26:37 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id dx3so31893062pab.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:26:37 -0700 (PDT)
Date: Thu, 14 Jul 2016 13:26:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: System freezes after OOM
In-Reply-To: <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1607141324290.68666@chino.kir.corp.google.com>
References: <20160713133955.GK28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131004340.31769@file01.intranet.prod.int.rdu2.redhat.com> <20160713145638.GM28723@dhcp22.suse.cz> <alpine.LRH.2.02.1607131105080.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.10.1607131644590.92037@chino.kir.corp.google.com> <201607142001.BJD07258.SMOHFOJVtLFOQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mpatocka@redhat.com, mhocko@kernel.org, okozina@redhat.com, jmarchan@redhat.com, skozina@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 14 Jul 2016, Tetsuo Handa wrote:

> David Rientjes wrote:
> > On Wed, 13 Jul 2016, Mikulas Patocka wrote:
> > 
> > > What are the real problems that f9054c70d28bc214b2857cf8db8269f4f45a5e23 
> > > tries to fix?
> > > 
> > 
> > It prevents the whole system from livelocking due to an oom killed process 
> > stalling forever waiting for mempool_alloc() to return.  No other threads 
> > may be oom killed while waiting for it to exit.
> 
> Is that concern still valid? We have the OOM reaper for CONFIG_MMU=y case.
> 

Umm, show me an explicit guarantee where the oom reaper will free memory 
such that other threads may return memory to this process's mempool so it 
can make forward progress in mempool_alloc() without the need of utilizing 
memory reserves.  First, it might be helpful to show that the oom reaper 
is ever guaranteed to free any memory for a selected oom victim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
