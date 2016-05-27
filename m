Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1258C6B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 07:08:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n2so59360974wma.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:08:03 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ee4si25221588wjd.121.2016.05.27.04.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 04:08:01 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e3so13777576wme.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:08:01 -0700 (PDT)
Date: Fri, 27 May 2016 13:07:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160527110759.GF27686@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-7-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464266415-15558-7-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

I have updated the patch to not rely on the mm_users check because it is
not reliable as pointed by Tetsuo and we really want this function to be
reliable. I do not have a good and reliable way to check for existence
of external users sharing the mm so we are checking the whole list
unconditionally if mm_users > 1. This should be acceptable because we
are doing this only in the slow path of task_will_free_mem. We can
surely make this more optimum later.
---
