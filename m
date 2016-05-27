Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93BDB6B025F
	for <linux-mm@kvack.org>; Fri, 27 May 2016 07:18:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a136so59572974wme.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:18:06 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id l186si11578130wml.88.2016.05.27.04.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 04:18:05 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id e3so13856631wme.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:18:05 -0700 (PDT)
Date: Fri, 27 May 2016 13:18:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160527111803.GG27686@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464266415-15558-4-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

And here again. Get rid of the mm_users check because it is not
reliable.
---
