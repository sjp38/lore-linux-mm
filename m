Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 039C46B0009
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 00:30:49 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 69-v6so8873386plc.18
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 21:30:48 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r72si7853167pfa.338.2018.03.23.21.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Mar 2018 21:30:47 -0700 (PDT)
Date: Fri, 23 Mar 2018 21:30:44 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180324043044.GA22733@bombadil.infradead.org>
References: <1521851771-108673-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1521851771-108673-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: adobriyan@gmail.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> So, introduce a new rwlock in mm_struct to protect the concurrent access
> to arg_start|end and env_start|end.

I don't think an rwlock makes much sense here.  There is almost no
concurrency on the read side, and an rwlock is more expensive than
a spinlock.  Just use a spinlock.
