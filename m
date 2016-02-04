Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 811624403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:11:19 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id x21so14755461oix.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:11:19 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k9si3254494oif.143.2016.02.04.05.11.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 05:11:18 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<20160203132718.GI6757@dhcp22.suse.cz>
	<alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
	<20160204125700.GA14425@dhcp22.suse.cz>
In-Reply-To: <20160204125700.GA14425@dhcp22.suse.cz>
Message-Id: <201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
Date: Thu, 4 Feb 2016 22:10:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> I am not sure we can fix these pathological loads where we hit the
> higher order depletion and there is a chance that one of the thousands
> tasks terminates in an unpredictable way which happens to race with the
> OOM killer.

When I hit this problem on Dec 24th, I didn't run thousands of tasks.
I think there were less than one hundred tasks in the system and only
a few tasks were running. Not a pathological load at all.

I'm running thousands of tasks only for increasing the possibility
in the reproducer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
