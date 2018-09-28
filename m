Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 69F018E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 17:21:42 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id r205-v6so1561861lff.4
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 14:21:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s90-v6sor715840lje.16.2018.09.28.14.21.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 14:21:41 -0700 (PDT)
Date: Sat, 29 Sep 2018 00:21:38 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Fix int overflow in callers of do_shrink_slab()
Message-ID: <20180928212138.GS15710@uranus>
References: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
 <20180928141509.fd8f8ac8c0ea61f0cb79d494@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180928141509.fd8f8ac8c0ea61f0cb79d494@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, mhocko@suse.com, aryabinin@virtuozzo.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 28, 2018 at 02:15:09PM -0700, Andrew Morton wrote:
> What did he report?  Was it code inspection?  Did the kernel explode? 
> etcetera.  I'm thinking that the fix should be backported but to
> determine that, we need to understand the end-user runtime effects, as
> always.  Please.

I've been investigating unrelated but and occasionally found this nit.
Look, there should be over 4G of objects scanned to have it triggered,
so I don't expect it happen in real life but better be on a safe side
and fix it.
