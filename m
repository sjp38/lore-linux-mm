Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9776B025D
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:00:07 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so117677755pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:00:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i16si38016040pbq.81.2015.09.21.07.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 07:00:06 -0700 (PDT)
Date: Mon, 21 Sep 2015 15:57:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150921135704.GA17804@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com> <55FF03F4.6000904@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55FF03F4.6000904@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/20, Raymond Jennings wrote:
>
> On 09/20/15 11:05, Linus Torvalds wrote:
>>
>> which can be called from just about any context (but atomic
>> allocations will never get here, so it can schedule etc).
>
> I think in this case the oom killer should just slap a SIGKILL on the
> task and then back out, and whatever needed the memory should just wait
> patiently for the sacrificial lamb to commit seppuku.

Not sure I understand you correctly, but this is what we currently do.
The only problem is that this doesn't work sometimes.

> Also, I observed that a task in the middle of dumping core doesn't
> respond to signals while it's dumping,

How did you observe this? The coredumping is killable.

Although yes, we have problems here in oom condition. In particular
with CLONE_VM tasks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
