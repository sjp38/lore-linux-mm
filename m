Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 813D96B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 18:22:54 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e65so183683161pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:22:54 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id m68si50522798pfj.133.2016.01.19.15.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 15:22:53 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id uo6so445505652pac.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 15:22:53 -0800 (PST)
Date: Tue, 19 Jan 2016 15:22:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: do not loop !__GFP_FS allocation if the OOM
 killer is disabled.
In-Reply-To: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601191522090.7346@chino.kir.corp.google.com>
References: <1452488836-6772-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, linux-mm@kvack.org

On Mon, 11 Jan 2016, Tetsuo Handa wrote:

> After the OOM killer is disabled during suspend operation,
> any !__GFP_NOFAIL && __GFP_FS allocations are forced to fail.
> Thus, any !__GFP_NOFAIL && !__GFP_FS allocations should be
> forced to fail as well.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Please update this patch with the suggested comment from Johannes.  After 
that's done, feel free to add my

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
