Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 738EE6B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 15:39:34 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 55so4518131wrx.21
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 12:39:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x18si4056601wmd.75.2017.11.30.12.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 12:39:33 -0800 (PST)
Date: Thu, 30 Nov 2017 12:39:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
Message-Id: <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org>
In-Reply-To: <20171130152824.1591-1-guro@fb.com>
References: <20171130152824.1591-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 30 Nov 2017 15:28:17 +0000 Roman Gushchin <guro@fb.com> wrote:

> This patchset makes the OOM killer cgroup-aware.

Thanks, I'll grab these.

There has been controversy over this patchset, to say the least.  I
can't say that I followed it closely!  Could those who still have
reservations please summarise their concerns and hopefully suggest a
way forward?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
