Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC2876B0264
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:00:28 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id rs7so56528325lbb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:00:28 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ck5si26913779wjb.78.2016.05.27.09.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 09:00:27 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so15709835wmn.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:00:27 -0700 (PDT)
Date: Fri, 27 May 2016 18:00:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/5] Handle oom bypass more gracefully
Message-ID: <20160527160026.GA29337@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

JFYI, I plan to repost the series early next week after I review all the
pieces again properly with a clean head. If some parts are not sound or
completely unacceptable in principle then let me know of course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
