Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 066A16B0292
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 02:58:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w63so13621026wrc.5
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 23:58:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p9si8036898wrp.425.2017.08.06.23.58.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 06 Aug 2017 23:58:30 -0700 (PDT)
Date: Mon, 7 Aug 2017 08:58:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Message-ID: <20170807065827.GC32434@dhcp22.suse.cz>
References: <20170802105018.GA2529@dhcp22.suse.cz>
 <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
 <20170803081152.GC12521@dhcp22.suse.cz>
 <5aca0179-3b04-aa1a-58cd-668a04f63ae7@I-love.SAKURA.ne.jp>
 <20170803103337.GH12521@dhcp22.suse.cz>
 <201708031944.JCB39029.SJOOOLHFQFMVFt@I-love.SAKURA.ne.jp>
 <20170803110548.GK12521@dhcp22.suse.cz>
 <CAHC9VhQ_TtFPQL76OEui8_rfvDJ5i6AEdPdYLSHtn1vtWEKTOA@mail.gmail.com>
 <20170804075636.GD26029@dhcp22.suse.cz>
 <CAHC9VhR_SJUg2wkKhoeXHJeLrNFh=KYwSgz-5X57xx0Maa95Mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHC9VhR_SJUg2wkKhoeXHJeLrNFh=KYwSgz-5X57xx0Maa95Mg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@tycho.nsa.gov

On Fri 04-08-17 13:12:04, Paul Moore wrote:
> On Fri, Aug 4, 2017 at 3:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > Btw. Should I resend the patch or somebody will take it from this email
> > thread?
> 
> No, unless your mailer mangled the patch I should be able to pull it
> from this thread.  However, I'm probably going to let this sit until
> early next week on the odd chance that anyone else wants to comment on
> the flag choice.  I'll send another reply once I merge the patch.

OK, there is certainly no hurry for merging this. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
