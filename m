Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 886DC6B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 21:56:00 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id x14-v6so29196342ioa.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 18:56:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u206-v6si5933031itc.35.2018.07.13.18.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 18:55:59 -0700 (PDT)
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
References: <20171130152824.1591-1-guro@fb.com>
 <20180605114729.GB19202@dhcp22.suse.cz>
 <alpine.DEB.2.21.1807131438380.194789@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0a86d2a7-b78e-7e69-f628-aa2c75d91ff0@i-love.sakura.ne.jp>
Date: Sat, 14 Jul 2018 10:55:41 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807131438380.194789@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/07/14 6:59, David Rientjes wrote:
> I'm not trying to preclude the cgroup-aware oom killer from being merged,
> I'm the only person actively trying to get it merged.

Before merging the cgroup-aware oom killer, can we merge OOM lockup fixes
and my cleanup? The gap between linux.git and linux-next.git keeps us unable
to use agreed baseline.
