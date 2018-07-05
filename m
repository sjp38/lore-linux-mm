Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8622E6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 18:10:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so2996612plv.0
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 15:10:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i14-v6si5201768pgp.155.2018.07.05.15.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 15:10:42 -0700 (PDT)
Date: Thu, 5 Jul 2018 15:10:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 05/17] mm: Assign memcg-aware shrinkers bitmap to
 memcg
Message-Id: <20180705151030.c67eb9a989c5f0023a53d415@linux-foundation.org>
In-Reply-To: <aaa98988-29e9-fb81-1d36-6b8bd7a371be@virtuozzo.com>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
	<153063056619.1818.12550500883688681076.stgit@localhost.localdomain>
	<20180703135000.b2322ae0e514f028e7941d3c@linux-foundation.org>
	<aaa98988-29e9-fb81-1d36-6b8bd7a371be@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Wed, 4 Jul 2018 18:51:12 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> > - why aren't we decreasing shrinker_nr_max in
> >   unregister_memcg_shrinker()?  That's easy to do, avoids pointless
> >   work in shrink_slab_memcg() and avoids memory waste in future
> >   prealloc_memcg_shrinker() calls.
> 
> You sure, but there are some things. Initially I went in the same way
> as memcg_nr_cache_ids is made and just took the same x2 arithmetic.
> It never decreases, so it looked good to make shrinker maps like it.
> It's the only reason, so, it should not be a problem to rework.
> 
> The only moment is Vladimir strongly recommends modularity, i.e.
> to have memcg_shrinker_map_size and shrinker_nr_max as different variables.

For what reasons?

> After the rework we won't be able to have this anymore, since memcontrol.c
> will have to know actual shrinker_nr_max value and it will have to be exported.
>
> Could this be a problem?

Vladimir?
