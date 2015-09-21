Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id C99DD6B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 12:55:47 -0400 (EDT)
Received: by iofb144 with SMTP id b144so127037711iof.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:55:47 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id f77si17828004ioi.34.2015.09.21.09.55.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 09:55:47 -0700 (PDT)
Received: by iofb144 with SMTP id b144so127037415iof.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 09:55:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150921134414.GA15974@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
	<CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
	<20150920125642.GA2104@redhat.com>
	<CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
	<20150921134414.GA15974@redhat.com>
Date: Mon, 21 Sep 2015 09:55:46 -0700
Message-ID: <CA+55aFzWP5X7pnhttr-uGnJCcRkNoJjdhHdWfAcrOKSrBm39SA@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Mon, Sep 21, 2015 at 6:44 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> I must have missed something. I can't understand your and Michal's
> concerns.

Heh.  I looked at that patch, and apparently entirely missed the
queue_work() part of the whole patch, thinking it was a direct call.

So never mind.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
