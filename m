Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C71866B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 10:47:51 -0400 (EDT)
Received: by qgx61 with SMTP id 61so60001824qgx.3
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 07:47:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m75si12933331qki.120.2015.09.19.07.47.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 07:47:51 -0700 (PDT)
Date: Sat, 19 Sep 2015 16:44:51 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150919144451.GA31952@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org> <20150919083218.GD28815@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150919083218.GD28815@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On 09/19, Michal Hocko wrote:
>
> This has been posted in various forms many times over past years. I
> still do not think this is a right approach of dealing with the problem.

Agreed. But still I think it makes sense to try to kill another task
if the victim refuse to die. Yes, the details are not clear to me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
