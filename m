Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD456B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 03:02:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g32so11701114wrd.8
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 00:02:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y67si4220183wmy.237.2017.08.10.00.02.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 00:02:08 -0700 (PDT)
Date: Thu, 10 Aug 2017 09:02:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Message-ID: <20170810070206.GA23863@dhcp22.suse.cz>
References: <20170803081152.GC12521@dhcp22.suse.cz>
 <5aca0179-3b04-aa1a-58cd-668a04f63ae7@I-love.SAKURA.ne.jp>
 <20170803103337.GH12521@dhcp22.suse.cz>
 <201708031944.JCB39029.SJOOOLHFQFMVFt@I-love.SAKURA.ne.jp>
 <20170803110548.GK12521@dhcp22.suse.cz>
 <CAHC9VhQ_TtFPQL76OEui8_rfvDJ5i6AEdPdYLSHtn1vtWEKTOA@mail.gmail.com>
 <20170804075636.GD26029@dhcp22.suse.cz>
 <CAHC9VhR_SJUg2wkKhoeXHJeLrNFh=KYwSgz-5X57xx0Maa95Mg@mail.gmail.com>
 <20170807065827.GC32434@dhcp22.suse.cz>
 <CAHC9VhRGmBn7EA1iLzHjv2A3nawc5ZtZs+cjdVm4BUX0wGGHVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHC9VhRGmBn7EA1iLzHjv2A3nawc5ZtZs+cjdVm4BUX0wGGHVA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: mgorman@suse.de, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@tycho.nsa.gov

On Tue 08-08-17 09:34:15, Paul Moore wrote:
> On Mon, Aug 7, 2017 at 2:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 04-08-17 13:12:04, Paul Moore wrote:
> >> On Fri, Aug 4, 2017 at 3:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> >> > Btw. Should I resend the patch or somebody will take it from this email
> >> > thread?
> >>
> >> No, unless your mailer mangled the patch I should be able to pull it
> >> from this thread.  However, I'm probably going to let this sit until
> >> early next week on the odd chance that anyone else wants to comment on
> >> the flag choice.  I'll send another reply once I merge the patch.
> >
> > OK, there is certainly no hurry for merging this. Thanks!
> > --
> > Michal Hocko
> > SUSE Labs
> 
> Merged into selinux/next with this patch description, and your
> sign-off (I had to munge the description a bit based on the thread).
> Are you okay with this, especially your sign-off?

Yes. Thanks!

> 
>   commit 476accbe2f6ef69caeebe99f52a286e12ac35aee
>   Author: Michal Hocko <mhocko@kernel.org>
>   Date:   Thu Aug 3 10:11:52 2017 +0200
> 
>    selinux: use GFP_NOWAIT in the AVC kmem_caches
> 
>    There is a strange __GFP_NOMEMALLOC usage pattern in SELinux,
>    specifically GFP_ATOMIC | __GFP_NOMEMALLOC which doesn't make much
>    sense.  GFP_ATOMIC on its own allows to access memory reserves while
>    __GFP_NOMEMALLOC dictates we cannot use memory reserves.  Replace this
>    with the much more sane GFP_NOWAIT in the AVC code as we can tolerate
>    memory allocation failures in that code.
> 
>    Signed-off-by: Michal Hocko <mhocko@kernel.org>
>    Acked-by: Mel Gorman <mgorman@suse.de>
>    Signed-off-by: Paul Moore <paul@paul-moore.com>
> 
> -- 
> paul moore
> www.paul-moore.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
