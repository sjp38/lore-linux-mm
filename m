Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6CF6B071D
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 03:56:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z48so4892932wrc.4
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 00:56:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si2166678wrn.74.2017.08.04.00.56.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 00:56:38 -0700 (PDT)
Date: Fri, 4 Aug 2017 09:56:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Message-ID: <20170804075636.GD26029@dhcp22.suse.cz>
References: <20170802105018.GA2529@dhcp22.suse.cz>
 <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
 <20170803081152.GC12521@dhcp22.suse.cz>
 <5aca0179-3b04-aa1a-58cd-668a04f63ae7@I-love.SAKURA.ne.jp>
 <20170803103337.GH12521@dhcp22.suse.cz>
 <201708031944.JCB39029.SJOOOLHFQFMVFt@I-love.SAKURA.ne.jp>
 <20170803110548.GK12521@dhcp22.suse.cz>
 <CAHC9VhQ_TtFPQL76OEui8_rfvDJ5i6AEdPdYLSHtn1vtWEKTOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHC9VhQ_TtFPQL76OEui8_rfvDJ5i6AEdPdYLSHtn1vtWEKTOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@tycho.nsa.gov

On Thu 03-08-17 14:17:26, Paul Moore wrote:
> On Thu, Aug 3, 2017 at 7:05 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 03-08-17 19:44:46, Tetsuo Handa wrote:
[...]
> >> When allocating thread is selected as an OOM victim, it gets TIF_MEMDIE.
> >> Since that function might be called from !in_interrupt() context, it is
> >> possible that gfp_pfmemalloc_allowed() returns true due to TIF_MEMDIE and
> >> the OOM victim will dip into memory reserves even when allocation failure
> >> is not a problem.
> >
> > Yes this is possible but I do not see any major problem with that.
> > I wouldn't add __GFP_NOMEMALLOC unless there is a real runaway of some
> > sort that could be abused.
> 
> Adding __GFP_NOMEMALLOC would not hurt anything would it?

I is not harmfull but I fail to see how it would be useful either and as
such it just adds a pointless gfp flag and confusion to whoever tries to
modify the code in future. Really the main purpose of __GFP_NOMEMALLOC
is to override the process scope PF_MEMALLOC. As such it is quite a hack
and the fewer users we have the better.

Btw. Should I resend the patch or somebody will take it from this email
thread?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
