Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA6866B05CA
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 06:50:23 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k71so5554564wrc.15
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 03:50:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w20si14424196wra.281.2017.08.02.03.50.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 03:50:20 -0700 (PDT)
Date: Wed, 2 Aug 2017 12:50:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: suspicious __GFP_NOMEMALLOC in selinux
Message-ID: <20170802105018.GA2529@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Vander Stoep <jeffv@google.com>
Cc: Paul Moore <pmoore@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
while doing something completely unrelated to selinux I've noticed a
really strange __GFP_NOMEMALLOC usage pattern in selinux, especially
GFP_ATOMIC | __GFP_NOMEMALLOC doesn't make much sense to me. GFP_ATOMIC
on its own allows to access memory reserves while the later flag tells
we cannot use memory reserves at all. The primary usecase for
__GFP_NOMEMALLOC is to override a global PF_MEMALLOC should there be a
need.

It all leads to fa1aa143ac4a ("selinux: extended permissions for
ioctls") which doesn't explain this aspect so let me ask. Why is the
flag used at all? Moreover shouldn't GFP_ATOMIC be actually GFP_NOWAIT.
What makes this path important to access memory reserves?

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
