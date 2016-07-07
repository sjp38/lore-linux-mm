Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C00EF6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 04:42:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so13142971wme.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 01:42:02 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id p6si1075805wjx.285.2016.07.07.01.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 01:42:01 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i4so3340422wmg.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 01:42:01 -0700 (PDT)
Date: Thu, 7 Jul 2016 10:42:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160707084159.GE5379@dhcp22.suse.cz>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160703151829.GA28667@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Sun 03-07-16 17:18:29, Oleg Nesterov wrote:
[...]
> Or perhaps we can change oom_kill_process() to send SIGKILL to kthreads as
> well, this should not have any effect unless kthread does allow_signal(SIGKILL),
> then we can change vhost_worker() to catch SIGKILL and react somehow. Not sure
> this is really possible.

But then we would have to check for the signal after every memory
access no? This sounds much more error prone than the test being wrapped
inside the copy_from... API to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
