Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 327A36B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 08:03:38 -0400 (EDT)
Received: by oibi136 with SMTP id i136so7758381oib.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 05:03:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id vw9si18908964oeb.71.2015.10.07.05.03.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 05:03:37 -0700 (PDT)
Date: Wed, 7 Oct 2015 14:00:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151007120016.GB20428@redhat.com>
References: <20150921153252.GA21988@redhat.com> <20150921161203.GD19811@dhcp22.suse.cz> <20150922160608.GA2716@redhat.com> <20150923205923.GB19054@dhcp22.suse.cz> <20151006184502.GA15787@redhat.com> <201510072003.DCC69259.tJOOFOFFMLQSVH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510072003.DCC69259.tJOOFOFFMLQSVH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 10/07, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > Anyway. Perhaps it makes sense to abort the for_each_vma() loop if
> > freed_enough_mem() == T. But it is absolutely not clear to me how we
> > should define this freed_enough_mem(), so I think we should do this
> > later.
>
> Maybe
>
>   bool freed_enough_mem(void) { !atomic_read(&oom_victims); }
>
> if we change to call mark_oom_victim() on all threads which should be
> killed as OOM victims.

Well, in this case

	if (atomic_read(&mm->mm_users) == 1)
		break;

makes much more sense. Plus we do not need to change mark_oom_victim().

Lets discuss this later?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
