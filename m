Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9206B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:15:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q22so4523678pfh.20
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:15:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z62si11437593pfb.305.2018.03.26.08.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 26 Mar 2018 08:15:42 -0700 (PDT)
Date: Mon, 26 Mar 2018 08:14:06 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/10] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180326151406.GE10912@bombadil.infradead.org>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
 <20180324184009.dyjlt4rj4b6y6sz3@esperanza>
 <0db2d93f-12cd-d703-fce7-4c3b8df5bc12@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0db2d93f-12cd-d703-fce7-4c3b8df5bc12@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 26, 2018 at 06:09:35PM +0300, Kirill Tkhai wrote:
> > AFAIK ida always allocates the smallest available id so you don't need
> > to keep track of bitmap_id_start.
> 
> I saw mnt_alloc_group_id() does the same, so this was the reason, the additional
> variable was used. Doesn't this gives a good advise to ida and makes it find
> a free id faster?

No, it doesn't help the IDA in the slightest.  I have a patch in my
tree to delete that silliness from mnt_alloc_group_id(); just haven't
submitted it yet.
