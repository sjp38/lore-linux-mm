Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 26AEA6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 10:19:27 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so101044371wgd.2
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 07:19:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si8697902wix.3.2015.03.27.07.19.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 07:19:25 -0700 (PDT)
Date: Fri, 27 Mar 2015 15:19:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150327141922.GC5481@dhcp22.suse.cz>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, cl@linux.com, linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, vinmenon@codeaurora.org, shashim@codeaurora.org, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, linux-mm@kvack.org

On Thu 26-03-15 11:09:01, Viresh Kumar wrote:
> A delayed work to schedule vmstat_shepherd() is queued at periodic intervals for
> internal working of vmstat core. This work and its timer end up waking an idle
> cpu sometimes, as this always stays on CPU0.
> 
> Because we re-queue the work from its handler, idle_cpu() returns false and so
> the timer (used by delayed work) never migrates to any other CPU.
> 
> This may not be the desired behavior always as waking up an idle CPU to queue
> work on few other CPUs isn't good from power-consumption point of view.

Wouldn't something like I was suggesting few months back
(http://article.gmane.org/gmane.linux.kernel.mm/127569) solve this
problem as well? Scheduler should be idle aware, no? I mean it shouldn't
wake up an idle CPU if the task might run on another one.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
