Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB9D828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 16:24:29 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i44so132882367qte.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 13:24:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r62si62917qkd.169.2016.06.29.13.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 13:24:27 -0700 (PDT)
Date: Wed, 29 Jun 2016 22:24:24 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160629202424.GC19253@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627204016.GA31239@redhat.com>
 <20160628102959.GC510@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160628102959.GC510@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/28, Michal Hocko wrote:
>
> On Mon 27-06-16 22:40:17, Oleg Nesterov wrote:
> >
> > Ah, but this is clear, note the "Ignoring the obvious races" above.
> > Can't we fix this race? I am a bit lost, but iirc we want this anyway
> > to ensure that we do not set TIF_MEMDIE if ->mm == NULL ?
>
> This is not about a race it is about not reaching exit_oom_victim and
> unblock the oom killer from selecting another victim.

I understand. What I do not understand why we can't rely on MMF_OOM_REAPED
if we ensure that TIF_MEMDIE can only be set if the victim did not call
exit_oom_victim() yet.

OK, please forget, I already got lost and right now I don't even have the
uptodate -mm tree sources.

> > Hmm. Although I am not sure I really understand the "may block for
> > unbounded period ..." above. Do you mean khugepaged_exit?
>
> __mmput->exit_aio can wait for IO to complete and who knows what that
> might depend on.

Yes, but I was confused by "waiting for somebody else's memory allocation",
I do not this this apllies to exit_aio.

Nevermind,

> Who knows how many others are lurking there.

Yes, yes, I agree. Just I wrongly thought Tetsuo meant something particular.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
