Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD3888E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:34:22 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id e23-v6so1627036ljj.22
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:34:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q21-v6sor1979465lfi.0.2018.09.28.04.34.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 04:34:21 -0700 (PDT)
Date: Fri, 28 Sep 2018 14:34:18 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Fix int overflow in callers of do_shrink_slab()
Message-ID: <20180928113418.GR15710@uranus>
References: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153813407177.17544.14888305435570723973.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, aryabinin@virtuozzo.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

Thank you!
