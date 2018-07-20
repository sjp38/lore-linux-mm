Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF6E86B0010
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:02:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t20-v6so6621548pgu.9
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:02:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t69-v6sor796518pgd.355.2018.07.20.13.02.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 13:02:34 -0700 (PDT)
Date: Fri, 20 Jul 2018 13:02:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: thp: remove use_zero_page sysfs knob
In-Reply-To: <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1807201300290.224013@chino.kir.corp.google.com>
References: <1532110430-115278-1-git-send-email-yang.shi@linux.alibaba.com> <20180720123243.6dfc95ba061cd06e05c0262e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, kirill@shutemov.name, hughd@google.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Jul 2018, Andrew Morton wrote:

> > By digging into the original review, it looks use_zero_page sysfs knob
> > was added to help ease-of-testing and give user a way to mitigate
> > refcounting overhead.
> > 
> > It has been a few years since the knob was added at the first place, I
> > think we are confident that it is stable enough. And, since commit
> > 6fcb52a56ff60 ("thp: reduce usage of huge zero page's atomic counter"),
> > it looks refcounting overhead has been reduced significantly.
> > 
> > Other than the above, the value of the knob is always 1 (enabled by
> > default), I'm supposed very few people turn it off by default.
> > 
> > So, it sounds not worth to still keep this knob around.
> 
> Probably OK.  Might not be OK, nobody knows.
> 
> It's been there for seven years so another six months won't kill us. 
> How about as an intermediate step we add a printk("use_zero_page is
> scheduled for removal.  Please contact linux-mm@kvack.org if you need
> it").
> 

We disable the huge zero page through this interface, there were issues 
related to the huge zero page shrinker (probably best to never free a 
per-node huge zero page after allocated) and CVE-2017-1000405 for huge 
dirty COW.
