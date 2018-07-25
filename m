Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAEF26B02AA
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:01:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so3094810edr.4
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 06:01:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w13-v6si4625348eds.45.2018.07.25.06.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 06:01:24 -0700 (PDT)
Date: Wed, 25 Jul 2018 15:01:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: cgroup-aware OOM killer, how to move forward
Message-ID: <20180725130123.GM28386@dhcp22.suse.cz>
References: <20180711223959.GA13981@castle.DHCP.thefacebook.com>
 <9ef76b45-d50f-7dc6-d224-683ab23efdb0@I-love.SAKURA.ne.jp>
 <20180725001001.GA30802@castle.DHCP.thefacebook.com>
 <33510f1b-e038-8266-6482-f8f8891e5514@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33510f1b-e038-8266-6482-f8f8891e5514@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, gthelen@google.com

On Wed 25-07-18 21:23:11, Tetsuo Handa wrote:
> Michal, I think that I hit WQ OOM lockup caused by lack of guaranteed schedule_timeout_*() for WQ.
> I think we should immediately send https://marc.info/?l=linux-mm&m=153062798103081
> (or both http://lkml.kernel.org/r/20180709074706.30635-1-mhocko@kernel.org and
> https://marc.info/?l=linux-mm&m=152723708623015 ) to linux.git so that we can send
> to stable kernels without waiting for "mm, oom: cgroup-aware OOM killer" patchset.

Then do not pollute unrelated threads. Really! The patch to drop the
sleep from the oom_lock is in mmotm tree already. I really do not see
why you make it more important than it really is (ohhh it is the dubious
CVE you have filed?).

If you have hit a WQ OOM lockup beucase of a missing schedule_timeout
then report it in a new email thread and we can discuss the proper way
of handling it.

Thanks!
-- 
Michal Hocko
SUSE Labs
