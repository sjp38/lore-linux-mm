Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1966B000A
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 10:55:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w10so10325645wrg.15
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 07:55:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e131si10152887wmg.242.2018.03.26.07.55.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Mar 2018 07:55:08 -0700 (PDT)
Date: Mon, 26 Mar 2018 16:55:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180326145505.GM5652@dhcp22.suse.cz>
References: <1521851771-108673-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180324043044.GA22733@bombadil.infradead.org>
 <aed7f679-a32f-d8d7-eb59-ec05fc49a70e@linux.alibaba.com>
 <a766b98b-80b4-5f1b-9588-dd1c5506cbdc@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a766b98b-80b4-5f1b-9588-dd1c5506cbdc@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <willy@infradead.org>, adobriyan@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 26-03-18 23:49:18, Tetsuo Handa wrote:
[...]
> Also, even if we succeeded to avoid mmap_sem contention at that location,
> won't we after all get mmap_sem contention messages a bit later, for
> access_remote_vm() holds mmap_sem which would lead to traces like above
> if mmap_sem is already contended?

Yes, but at least we get rid of the mmap_sem for something that can use
a more fine grained locking.

Maybe we can get a finer grained range locking for mmap_sem one day and
not having the full range locked section will be a plus.

-- 
Michal Hocko
SUSE Labs
