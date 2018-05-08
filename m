Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 435516B0283
	for <linux-mm@kvack.org>; Tue,  8 May 2018 10:03:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b192-v6so5243786wmb.1
        for <linux-mm@kvack.org>; Tue, 08 May 2018 07:03:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u91-v6si861446edc.270.2018.05.08.07.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 07:03:55 -0700 (PDT)
Date: Tue, 8 May 2018 10:05:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180508140533.GA2900@cmpxchg.org>
References: <20180507210135.1823-7-hannes@cmpxchg.org>
 <201805080952.2yQWmzU2%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805080952.2yQWmzU2%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Tue, May 08, 2018 at 11:04:09AM +0800, kbuild test robot wrote:
>    118	#else /* CONFIG_PSI */
>    119	static inline void psi_enqueue(struct task_struct *p, u64 now)
>    120	{
>    121	}
>    122	static inline void psi_dequeue(struct task_struct *p, u64 now)
>    123	{
>    124	}
>    125	static inline void psi_ttwu_dequeue(struct task_struct *p) {}
>  > 126	{
>    127	}

Stupid last-minute cleanup reshuffling. v2 will have:

diff --git a/kernel/sched/stats.h b/kernel/sched/stats.h
index cb4a68bcf37a..ff6256b3d216 100644
--- a/kernel/sched/stats.h
+++ b/kernel/sched/stats.h
@@ -122,7 +122,7 @@ static inline void psi_enqueue(struct task_struct *p, u64 now)
 static inline void psi_dequeue(struct task_struct *p, u64 now)
 {
 }
-static inline void psi_ttwu_dequeue(struct task_struct *p) {}
+static inline void psi_ttwu_dequeue(struct task_struct *p)
 {
 }
 #endif /* CONFIG_PSI */
