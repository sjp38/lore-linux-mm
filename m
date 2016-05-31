Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDA526B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:41:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 132so68036053lfz.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:41:49 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 6si49089986wjh.22.2016.05.31.00.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 00:41:48 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e3so29707713wme.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:41:48 -0700 (PDT)
Date: Tue, 31 May 2016 09:41:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160531074146.GB26128@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464613556-16708-4-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

This got lost during the rebase.
---
