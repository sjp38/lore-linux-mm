Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B4C566B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 14:06:20 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v128so46945307qkh.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 11:06:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k15si3067156qke.143.2016.05.17.11.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 11:06:19 -0700 (PDT)
Date: Tue, 17 May 2016 20:06:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160517180616.GA32068@redhat.com>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
 <570E27D6.9060908@I-love.SAKURA.ne.jp>
 <20160413130858.GI14351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160413130858.GI14351@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 04/13, Michal Hocko wrote:
>
> On Wed 13-04-16 20:04:54, Tetsuo Handa wrote:
> > On 2016/04/12 18:19, Michal Hocko wrote:
> [...]
> > > Hi,
> > > I hope I got it right but I would really appreciate if Oleg found some
> > > time and double checked after me. The fix is more cosmetic than anything
> > > else but I guess it is worth it.
> >
> > I don't know what
> >
> >     fatal_signal_pending() can be true because of SIGNAL_GROUP_COREDUMP so
> >     out_of_memory() and mem_cgroup_out_of_memory() shouldn't blindly trust it.
> >
> > in commit d003f371b270 is saying (how SIGNAL_GROUP_COREDUMP can make
> > fatal_signal_pending() true when fatal_signal_pending() is defined as
>
> I guess this is about zap_process() but Olge would be more appropriate
> to clarify.


Yes, exactly, the dumper sends SIGKILL to other CLONE_THREAD and/or CLONE_VM
threads.

so I think the patch is fine, but let me write another email...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
