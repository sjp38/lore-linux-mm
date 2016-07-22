Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9676B6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 17:10:55 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id s189so261559682vkh.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 14:10:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k41si9943815qta.131.2016.07.22.14.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 14:10:55 -0700 (PDT)
Date: Fri, 22 Jul 2016 17:10:50 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 0/2] mm patches
Message-ID: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi

I'm submitting these two patches for the next merge window.

The first patch adds cond_resched() to generic_swapfile_activate to avoid 
stall when activating unfragmented swapfile.

The second patch removes useless code from copy_page_to_iter_iovec and 
copy_page_from_iter_iovec.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
