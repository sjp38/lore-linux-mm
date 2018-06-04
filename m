Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81E8F6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 15:07:31 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i1-v6so20938125pld.11
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 12:07:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i3-v6si45940222pld.189.2018.06.04.12.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 12:07:30 -0700 (PDT)
Date: Mon, 4 Jun 2018 12:07:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 00/17] Improve shrink_slab() scalability (old
 complexity was O(n^2), new is O(n))
Message-Id: <20180604120702.ef69c28585fe925f9a55e130@linux-foundation.org>
In-Reply-To: <0e725889-c42f-0557-ef41-76e4c87a3c9b@virtuozzo.com>
References: <152698356466.3393.5351712806709424140.stgit@localhost.localdomain>
	<0e725889-c42f-0557-ef41-76e4c87a3c9b@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Mon, 4 Jun 2018 15:45:17 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> Hi, Andrew!
> 
> This patchset is reviewed by Vladimir Davydov. I see, there is
> minor change in current linux-next.git, which makes the second
> patch to apply not completely clean.
> 
> Could you tell what should I do with this? Is this OK or should
> I rebase it on top of linux.next or do something else?

A resend against 4.18-rc1 would be ideal, thanks.
