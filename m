Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id A14954403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:37:37 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id m198so86041002lfm.0
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 04:37:37 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id w129si3922218lfd.40.2016.01.12.04.37.36
        for <linux-mm@kvack.org>;
        Tue, 12 Jan 2016 04:37:36 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: What is oom_killer_disable() for?
Date: Tue, 12 Jan 2016 13:38:09 +0100
Message-ID: <2751070.RBiEJZRJTx@vostro.rjw.lan>
In-Reply-To: <201601121917.IEI30296.OVOFFtQSLFHJOM@I-love.SAKURA.ne.jp>
References: <1452337485-8273-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20160111144924.GF27317@dhcp22.suse.cz> <201601121917.IEI30296.OVOFFtQSLFHJOM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, rientjes@google.com, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tuesday, January 12, 2016 07:17:19 PM Tetsuo Handa wrote:
> Michal Hocko write:

[cut]

> > I am not sure I am following you here but how do you detect that the
> > userspace has corrupted your image or accesses an already (half)
> > suspended device or something similar?
> 
> Can't we determine whether the OOM killer might have corrupted our image
> by checking whether oom_killer_disabled is kept true until the point of
> final decision?

The freezing is really not about keeping the image consistent etc.  It is
not about hibernation specifically even.

> To me, satisfying allocation requests by kernel threads by invoking the
> OOM killer and aborting suspend operation if the OOM killer was invoked
> sounds cleaner than forcing !__GFP_NOFAIL allocation requests to fail.

What if the suspend is on emergency, like low battery or thermal?

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
