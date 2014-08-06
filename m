Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id ED2576B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 16:59:16 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so3505238igd.14
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 13:59:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c16si14830897igo.4.2014.08.06.13.59.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Aug 2014 13:59:16 -0700 (PDT)
Date: Wed, 6 Aug 2014 13:59:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-memcontrol-rewrite-charge-api.patch and
 mm-memcontrol-rewrite-uncharge-api.patch
Message-Id: <20140806135914.9fca00159f6e3298c24a4ab3@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org


Do we feel these are ready for merging?

I'll send along the consolidated patches for eyeballs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
