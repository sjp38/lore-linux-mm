Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id 414626B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:55:57 -0500 (EST)
Received: by oiww189 with SMTP id w189so7393993oiw.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:55:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i17si9963463oib.131.2015.11.24.02.55.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 02:55:56 -0800 (PST)
Subject: Re: [PATCH] mm, vmstat: Allow WQ concurrency to discover memoryreclaim doesn't make any progress
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
	<20151124104220.GE29472@dhcp22.suse.cz>
In-Reply-To: <20151124104220.GE29472@dhcp22.suse.cz>
Message-Id: <201511241954.IBD52674.OHFQtOSMJFVLOF@I-love.SAKURA.ne.jp>
Date: Tue, 24 Nov 2015 19:54:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: tj@kernel.org, clameter@sgi.com, arekm@maven.pl, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:

> Ping... Are there any concerns about this patch?
> 
I'm OK with this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
