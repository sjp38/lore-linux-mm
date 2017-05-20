Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3C8A280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 22:10:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k57so7350314wrk.6
        for <linux-mm@kvack.org>; Fri, 19 May 2017 19:10:17 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id h80si12142224wmi.167.2017.05.19.19.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 19:10:16 -0700 (PDT)
Message-ID: <1495246207.7442.2.camel@gmx.de>
Subject: Re: [RFC PATCH v2 12/17] cgroup: Remove cgroup v2 no internal
 process constraint
From: Mike Galbraith <efault@gmx.de>
Date: Sat, 20 May 2017 04:10:07 +0200
In-Reply-To: <20170519203824.GC15279@wtj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
	 <1494855256-12558-13-git-send-email-longman@redhat.com>
	 <20170519203824.GC15279@wtj.duckdns.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net

On Fri, 2017-05-19 at 16:38 -0400, Tejun Heo wrote:
> Hello, Waiman.
> 
> On Mon, May 15, 2017 at 09:34:11AM -0400, Waiman Long wrote:
> > The rationale behind the cgroup v2 no internal process constraint is
> > to avoid resouorce competition between internal processes and child
> > cgroups. However, not all controllers have problem with internal
> > process competiton. Enforcing this rule may lead to unnatural process
> > hierarchy and unneeded levels for those controllers.
> 
> This isn't necessarily something we can determine by looking at the
> current state of controllers.  It's true that some controllers - pid
> and perf - inherently only care about membership of each task but at
> the same time neither really suffers from the constraint either.  CPU
> which is the problematic one here...

(+ cpuacct + cpuset)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
