Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C03998E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:35:50 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id b12-v6so5297522qtp.16
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:35:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o40-v6sor2609780qvh.118.2018.09.28.04.35.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 04:35:50 -0700 (PDT)
Date: Fri, 28 Sep 2018 07:35:48 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH] mm: Fix int overflow in callers of do_shrink_slab()
Message-ID: <20180928113546.sc7cztwsja4advli@destiny>
References: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gorcunov@openvz.org, mhocko@suse.com, aryabinin@virtuozzo.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 28, 2018 at 02:28:32PM +0300, Kirill Tkhai wrote:
> do_shrink_slab() returns unsigned long value, and
> the placing into int variable cuts high bytes off.
> Then we compare ret and 0xfffffffe (since SHRINK_EMPTY
> is converted to ret type).
> 
> Thus, big number of objects returned by do_shrink_slab()
> may be interpreted as SHRINK_EMPTY, if low bytes of
> their value are equal to 0xfffffffe. Fix that
> by declaration ret as unsigned long in these functions.
> 
> Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Reviewed-by: Josef Bacik <josef@toxicpanda.com>

Thanks,

Josef
