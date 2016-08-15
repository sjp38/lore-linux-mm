Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id B44166B0265
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 11:35:21 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id r9so117300322ywg.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:35:21 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m12si20525207wjq.88.2016.08.15.08.35.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 08:35:20 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so11746801wme.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 08:35:20 -0700 (PDT)
Date: Mon, 15 Aug 2016 17:35:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable-4.4 1/3] mm: memcontrol: fix cgroup creation
 failure after many small jobs
Message-ID: <20160815153516.GJ3360@dhcp22.suse.cz>
References: <1471273606-15392-1-git-send-email-mhocko@kernel.org>
 <1471273606-15392-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471273606-15392-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Nikolay Borisov <kernel@kyup.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Updated patch
---
