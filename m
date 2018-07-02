Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8898D6B027F
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 17:01:13 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i10-v6so6384299pgs.13
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 14:01:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k134-v6si15619777pga.149.2018.07.02.14.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 14:01:12 -0700 (PDT)
Date: Mon, 2 Jul 2018 14:01:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 REBASED 00/17] Improve shrink_slab() scalability (old
 complexity was O(n^2), new is O(n))
Message-Id: <20180702140109.38f65bdc5cb48b47f923b610@linux-foundation.org>
In-Reply-To: <46d951be-d3c4-91a0-0e33-711591914470@virtuozzo.com>
References: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
	<46d951be-d3c4-91a0-0e33-711591914470@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

On Mon, 2 Jul 2018 12:10:47 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> Hi, Andrew,
> 
> this series is made on top of 4.18-rc1, while now I see "mm-list_lru-add-lock_irq-member-to-__list_lru_init.patch"
> in mm tree, which conflicts with two of patches from series.

Well, "mm: use irq locking suffix instead local_irq_disable()" is a
fairly straightforward cleanup series, so it would be best to base your
patches on that work, please.

There is a significant review comment from Vladimir against "mm:
list_lru: add lock_irq member to __list_lru_init()" to which Sebastian
has yet to respond (please).

> Should I rebase the series on top of current mm tree? What are you plans on this series?

It looks like they're ready for an initial merge.
