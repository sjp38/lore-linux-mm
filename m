Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id D3E026B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 08:03:17 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so38516883ykd.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 05:03:17 -0700 (PDT)
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com. [209.85.160.178])
        by mx.google.com with ESMTPS id c22si3812126ywb.41.2015.09.23.05.03.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 05:03:16 -0700 (PDT)
Received: by ykdz138 with SMTP id z138so38510001ykd.2
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 05:03:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1509221631040.7794@chino.kir.corp.google.com>
References: <20150918162423.GA18136@redhat.com>
	<alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
	<20150919083218.GD28815@dhcp22.suse.cz>
	<201509192333.AGJ30797.OQOFLFSMJVFOtH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509211628050.27715@chino.kir.corp.google.com>
	<201509221433.ICI00012.VFOQMFHLFJtSOO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1509221631040.7794@chino.kir.corp.google.com>
Date: Wed, 23 Sep 2015 08:03:16 -0400
Message-ID: <CAEPKNTK3DOBApeVDpwJ_B7jkLVp4GQ0ihM1PwAusyc8TWQyB_A@mail.gmail.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
From: Kyle Walker <kwalker@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mhocko@kernel.org, Christoph Lameter <cl@linux.com>, Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stanislav Kozina <skozina@redhat.com>

On Tue, Sep 22, 2015 at 7:32 PM, David Rientjes <rientjes@google.com> wrote:
>
> I struggle to understand how the approach of randomly continuing to kill
> more and more processes in the hope that it slows down usage of memory
> reserves or that we get lucky is better.

Thank you to one and all for the feedback.

I agree, in lieu of treating TASK_UNINTERRUPTIBLE tasks as unkillable,
and omitting them from the oom selection process, continuing the
carnage is likely to result in more unpredictable results. At this
time, I believe Oleg's solution of zapping the process memory use
while it sleeps with the fatal signal enroute is ideal.

Kyle Walker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
