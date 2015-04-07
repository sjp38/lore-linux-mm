Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4B42A6B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 08:08:57 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so76961754pab.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 05:08:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bt5si11092962pdb.156.2015.04.07.05.08.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 05:08:56 -0700 (PDT)
Date: Tue, 7 Apr 2015 15:08:45 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC v2 0/3] idle memory tracking
Message-ID: <20150407120845.GA10286@esperanza>
References: <cover.1428401673.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1428401673.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Forgot to mention:

Originally, the patch for tracking idle memory was proposed back in 2011
by Michel Lespinasse (see http://lwn.net/Articles/459269/). The main
difference between Michel's patch and this one is that Michel
implemented a kernel space daemon for estimating idle memory size per
cgroup while this patch only provides the userspace with the minimal API
for doing the job, leaving the rest up to the userspace. However, they
both share the same idea of Idle/Young page flags to avoid affecting the
reclaimer logic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
