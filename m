Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 296456B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 04:14:28 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w141so697704wme.1
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 01:14:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n5si3347343edc.132.2017.12.01.01.14.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 01:14:26 -0800 (PST)
Date: Fri, 1 Dec 2017 10:14:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom: simplify alloc_pages_before_oomkill handling
Message-ID: <20171201091425.ekrpxsmkwcusozua@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130152824.1591-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Recently added alloc_pages_before_oomkill gained new caller with this
patchset and I think it just grown to deserve a simpler code flow.
What do you think about this on top of the series?

---
