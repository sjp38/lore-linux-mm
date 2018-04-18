Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4039B6B000D
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:16:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x184so1062588pfd.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:16:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b9si1296389pfn.100.2018.04.18.07.16.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 07:16:28 -0700 (PDT)
Subject: Re: [PATCH v2 01/12] mm: Assign id to every memcg-aware shrinker
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <152397794111.3456.1281420602140818725.stgit@localhost.localdomain>
	<152399118252.3456.17590357803686895373.stgit@localhost.localdomain>
In-Reply-To: <152399118252.3456.17590357803686895373.stgit@localhost.localdomain>
Message-Id: <201804182314.IIG86990.MFVJSFQLFOtHOO@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 23:14:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ktkhai@virtuozzo.com
Cc: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Kirill Tkhai wrote:
> The patch introduces shrinker::id number, which is used to enumerate
> memcg-aware shrinkers. The number start from 0, and the code tries
> to maintain it as small as possible.
> 
> This will be used as to represent a memcg-aware shrinkers in memcg
> shrinkers map.

I'm not reading this thread. But is there reason "id" needs to be managed
using smallest numbers? Can't we use address of shrinker object as "id"
(which will be sparse bitmap, and would be managed using linked list for now)?
