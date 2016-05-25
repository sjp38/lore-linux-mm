Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 639886B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 11:20:49 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 190so90494063iow.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:20:49 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0104.outbound.protection.outlook.com. [157.56.112.104])
        by mx.google.com with ESMTPS id c50si5888243otd.98.2016.05.25.08.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 May 2016 08:20:48 -0700 (PDT)
Date: Wed, 25 May 2016 18:20:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: oom_kill_process: do not abort if the victim is
 exiting
Message-ID: <20160525152040.GA23127@esperanza>
References: <1464092642-10363-1-git-send-email-vdavydov@virtuozzo.com>
 <20160524135042.GK8259@dhcp22.suse.cz>
 <20160524170746.GC11150@esperanza>
 <20160525080946.GC20132@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160525080946.GC20132@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 25, 2016 at 10:09:46AM +0200, Michal Hocko wrote:
...
> Well, my understanding of the OOM report is that it should tell you two
> things. The first one is to give you an overview of the overal memory
> situation when the system went OOM and the second one is o give you
> information that something has been _killed_ and what was the criteria
> why it has been selected (points). While the first one might be
> interesting for what you write above the second is not and it might be
> even misleading because we are not killing anything and the selected
> task is dying without the kernel intervention.

Fair enough. Printing that a task was killed while it actually died
voluntarily is not good. And select_bad_process may select dying tasks.
So let's leave it as is for now.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
