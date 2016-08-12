Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE666B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:56:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u81so2162595wmu.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:56:28 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id l77si1628462wmd.128.2016.08.12.02.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 02:56:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id q128so1922796wma.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 02:56:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.4 0/3] backport memcg id patches
Date: Fri, 12 Aug 2016 11:56:16 +0200
Message-Id: <1470995779-10064-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is my attempt to backport Johannes' 73f576c04b94 ("mm: memcontrol:
fix cgroup creation failure after many small jobs") to 4.4 based stable
kernel. The backport is not straightforward and there are 2 follow up
fixes on top of this commit. I would like to integrate these to our SLES
based kernel and believe other users might benefit from the backport as
well. All 3 patches are in the Linus tree already.

I would really appreciate if Johannes could double check after me before
this gets into the stable tree but my testing didn't reveal anything
unexpected.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
