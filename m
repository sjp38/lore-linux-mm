Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79EC56B007E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 18:04:37 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id c67so272891612vkh.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 15:04:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p68si20067593qkd.184.2016.05.20.15.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 15:04:36 -0700 (PDT)
Date: Sat, 21 May 2016 00:04:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520220432.GA22324@redhat.com>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160518141545.GI21654@dhcp22.suse.cz>
 <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
 <20160519065329.GA26110@dhcp22.suse.cz>
 <20160520015000.GA20132@redhat.com>
 <20160520064244.GD19172@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160520064244.GD19172@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On 05/20, Michal Hocko wrote:
>
> On Fri 20-05-16 03:50:01, Oleg Nesterov wrote:
> > On 05/19, Michal Hocko wrote:
> > >
> > > Long term I
> > > would like to to move this logic into the mm_struct, it would be just
> > > larger surgery I guess.
> >
> > Why we can't do this right now? Just another MMF_ flag set only once and
> > never cleared.
>
> It is more complicated and so more error prone.

Sure, but don't we want this anyway in the long term?

> We have to sort out
> shortcuts which get TIF_MEMDIE without killing first.

Yes, but this seems a bit "off-topic" to me... but probably I do not understand
the problem enough.

> And we have that
> nasty "mm shared between independant processes" case there.

Yes, yes, please see another email.

> If you feel that this step is not really worth it

No, no. Unless I see something which looks "obviously wrong" to me, I won't argue
with this (or any other) change as long as you and Tetsuo agree on it.

I understand that it is veru easy to blame OOM-killer (and the changes in this
area), but it is not easy to fix this code ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
