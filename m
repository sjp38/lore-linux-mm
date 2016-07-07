Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEC16B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 12:46:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c185so46806956qkd.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 09:46:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t187si2222439qkh.130.2016.07.07.09.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 09:46:07 -0700 (PDT)
Date: Thu, 7 Jul 2016 18:46:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160707164602.GC3063@redhat.com>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
 <20160707084159.GE5379@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707084159.GE5379@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On 07/07, Michal Hocko wrote:
>
> On Sun 03-07-16 17:18:29, Oleg Nesterov wrote:
> [...]
> > Or perhaps we can change oom_kill_process() to send SIGKILL to kthreads as
> > well, this should not have any effect unless kthread does allow_signal(SIGKILL),
> > then we can change vhost_worker() to catch SIGKILL and react somehow. Not sure
> > this is really possible.
>
> But then we would have to check for the signal after every memory
> access no? This sounds much more error prone than the test being wrapped
> inside the copy_from... API to me.

At least I agree this doesn't look nice too.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
