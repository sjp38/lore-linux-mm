Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC2C66B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 18:51:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b5-v6so5757585pfi.5
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 15:51:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c67-v6si7295069pfa.130.2018.07.05.15.51.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 15:51:08 -0700 (PDT)
Date: Thu, 5 Jul 2018 15:50:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v8 05/17] mm: Assign memcg-aware shrinkers bitmap to memcg
Message-ID: <20180705225004.GA26479@bombadil.infradead.org>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
 <153063056619.1818.12550500883688681076.stgit@localhost.localdomain>
 <20180703135000.b2322ae0e514f028e7941d3c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703135000.b2322ae0e514f028e7941d3c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Tue, Jul 03, 2018 at 01:50:00PM -0700, Andrew Morton wrote:
>   It should be possible to find the highest ID in an IDR tree with a
>   straightforward descent of the underlying radix tree, but I doubt if
>   that has been wired up.  Otherwise a simple loop in
>   unregister_memcg_shrinker() would be needed.

Feature request received.  I've actually implemented it for the XArray
already, but it should be easy to do for the IDR too.
