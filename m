Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2136B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:06:55 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id i184so116882597ywb.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:06:55 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 15si15743890wmw.62.2016.08.15.08.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:06:54 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so11612146wme.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:06:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH stable-4.4 0/3 v2] backport memcg id patches
Date: Mon, 15 Aug 2016 17:06:43 +0200
Message-Id: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
this is my attempt to backport Johannes' 73f576c04b94 ("mm: memcontrol:
fix cgroup creation failure after many small jobs") to 4.4 based stable
kernel. The backport is not straightforward and there are 2 follow up
fixes on top of this commit. I would like to integrate these to our SLES
based kernel and believe other users might benefit from the backport as
well. All 3 patches are in the Linus tree already.

This is the second version which addresses review feedback from Johannes [1]

[1] http://lkml.kernel.org/r/20160815123407.GA1153@cmpxchg.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
