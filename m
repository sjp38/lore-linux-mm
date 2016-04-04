Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id C81E26B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 03:31:04 -0400 (EDT)
Received: by mail-lf0-f41.google.com with SMTP id c126so36886938lfb.2
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 00:31:04 -0700 (PDT)
Received: from mail-lb0-f194.google.com (mail-lb0-f194.google.com. [209.85.217.194])
        by mx.google.com with ESMTPS id f79si15169338lfg.172.2016.04.04.00.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 00:31:03 -0700 (PDT)
Received: by mail-lb0-f194.google.com with SMTP id q4so20450102lbq.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 00:31:03 -0700 (PDT)
Date: Mon, 4 Apr 2016 09:31:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] mm/mmap.c: don't unmap the overlapping VMA(s)
Message-ID: <20160404073100.GA10272@dhcp22.suse.cz>
References: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, mtk.manpages@gmail.com, cmetcalf@mellanox.com, arnd@arndb.de, viro@zeniv.linux.org.uk, mszeredi@suse.cz, dave@stgolabs.net, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mingo@kernel.org, dan.j.williams@intel.com, dave.hansen@linux.intel.com, koct9i@gmail.com, hannes@cmpxchg.org, jack@suse.cz, xiexiuqi@huawei.com, iamjoonsoo.kim@lge.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, rientjes@google.com, denc716@gmail.com, toshi.kani@hpe.com, ldufour@linux.vnet.ibm.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Sat 02-04-16 21:17:31, Piotr Kwapulinski wrote:
> Currently the mmap(MAP_FIXED) discards the overlapping part of the
> existing VMA(s).
> Introduce the new MAP_DONTUNMAP flag which forces the mmap to fail
> with ENOMEM whenever the overlapping occurs and MAP_FIXED is set.
> No existing mapping(s) is discarded.

You forgot to tell us what is the use case for this new flag.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
