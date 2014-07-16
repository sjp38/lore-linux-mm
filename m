Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 14C1D6B004D
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 14:10:33 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so6196287wiv.0
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 11:10:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fb20si70694wjc.71.2014.07.16.11.10.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jul 2014 11:10:29 -0700 (PDT)
Date: Wed, 16 Jul 2014 14:10:07 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: memcg swap doesn't work in mmotm-2014-07-09-17-08?
Message-ID: <20140716181007.GA8524@nhori.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi,

It seems that when a process in some memcg tries to allocate more than
memcg.limit_in_bytes, oom happens instead of swaping out in
mmotm-2014-07-09-17-08 (memcg.memsw.limit_in_bytes is large enough).
It does work in v3.16-rc3, so I think latest patches changed something.
I'm not familiar with memcg internally, so no idea about what caused it.
Could you see the problem?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
