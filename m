Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 584AA6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 11:08:59 -0400 (EDT)
Received: by qkei195 with SMTP id i195so141852575qke.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 08:08:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r187si9240524qha.27.2015.07.07.08.08.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 08:08:58 -0700 (PDT)
Date: Tue, 7 Jul 2015 11:08:54 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 0/7] mm: reliable memory allocation with kvmalloc
Message-ID: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <msnitzer@redhat.com>
Cc: "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com

This patchset introduces function kvmalloc and kvmalloc_node. These 
functions allow reliable allocation of objects of arbitrary size. They 
attempt to do allocation with kmalloc and if it fails, use vmalloc. Memory 
allocated with these functions should be freed with kvfree.

The patchset makes modification to device mapper to use these functions.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
