Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A3E5A6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:17:48 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p63so72924664wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:17:48 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id vx5si22711700wjc.219.2016.01.29.07.17.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 07:17:47 -0800 (PST)
Date: Fri, 29 Jan 2016 16:17:39 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] workqueue: warn if memory reclaim tries to flush
 !WQ_MEM_RECLAIM workqueue
Message-ID: <20160129151739.GA1087@worktop>
References: <20151203002810.GJ19878@mtj.duckdns.org>
 <20151203093350.GP17308@twins.programming.kicks-ass.net>
 <20151203100018.GO11639@twins.programming.kicks-ass.net>
 <20151203144811.GA27463@mtj.duckdns.org>
 <20151203150442.GR17308@twins.programming.kicks-ass.net>
 <20151203150604.GC27463@mtj.duckdns.org>
 <20151203192616.GJ27463@mtj.duckdns.org>
 <20160126173843.GA11115@ulmo.nvidia.com>
 <20160128101210.GC6357@twins.programming.kicks-ass.net>
 <20160129110941.GK32380@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160129110941.GK32380@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Ulrich Obergfell <uobergfe@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Jon Hunter <jonathanh@nvidia.com>, linux-tegra@vger.kernel.org, rmk+kernel@arm.linux.org.uk, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Fri, Jan 29, 2016 at 06:09:41AM -0500, Tejun Heo wrote:
>  I posted a patch to disable
> disable flush dependency checks on those workqueues and there's a
> outreachy project to weed out the users of the old interface, so
> hopefully this won't be an issue soon.

Will that same project review all workqueue users for the strict per-cpu
stuff, so we can finally kill that weird stuff you do on hotplug?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
