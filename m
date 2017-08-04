Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC16A6B074B
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 13:12:07 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 65so4263799lfa.1
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 10:12:07 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id n25si1783017lja.43.2017.08.04.10.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 10:12:06 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id g25so9574360lfh.1
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 10:12:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170804075636.GD26029@dhcp22.suse.cz>
References: <20170802105018.GA2529@dhcp22.suse.cz> <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
 <20170803081152.GC12521@dhcp22.suse.cz> <5aca0179-3b04-aa1a-58cd-668a04f63ae7@I-love.SAKURA.ne.jp>
 <20170803103337.GH12521@dhcp22.suse.cz> <201708031944.JCB39029.SJOOOLHFQFMVFt@I-love.SAKURA.ne.jp>
 <20170803110548.GK12521@dhcp22.suse.cz> <CAHC9VhQ_TtFPQL76OEui8_rfvDJ5i6AEdPdYLSHtn1vtWEKTOA@mail.gmail.com>
 <20170804075636.GD26029@dhcp22.suse.cz>
From: Paul Moore <paul@paul-moore.com>
Date: Fri, 4 Aug 2017 13:12:04 -0400
Message-ID: <CAHC9VhR_SJUg2wkKhoeXHJeLrNFh=KYwSgz-5X57xx0Maa95Mg@mail.gmail.com>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@tycho.nsa.gov

On Fri, Aug 4, 2017 at 3:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 03-08-17 14:17:26, Paul Moore wrote:
>> On Thu, Aug 3, 2017 at 7:05 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Thu 03-08-17 19:44:46, Tetsuo Handa wrote:
> [...]
>> >> When allocating thread is selected as an OOM victim, it gets TIF_MEMDIE.
>> >> Since that function might be called from !in_interrupt() context, it is
>> >> possible that gfp_pfmemalloc_allowed() returns true due to TIF_MEMDIE and
>> >> the OOM victim will dip into memory reserves even when allocation failure
>> >> is not a problem.
>> >
>> > Yes this is possible but I do not see any major problem with that.
>> > I wouldn't add __GFP_NOMEMALLOC unless there is a real runaway of some
>> > sort that could be abused.
>>
>> Adding __GFP_NOMEMALLOC would not hurt anything would it?
>
> I is not harmfull but I fail to see how it would be useful either and as
> such it just adds a pointless gfp flag and confusion to whoever tries to
> modify the code in future. Really the main purpose of __GFP_NOMEMALLOC
> is to override the process scope PF_MEMALLOC. As such it is quite a hack
> and the fewer users we have the better.

Okay, that is a viable explanation for me.

> Btw. Should I resend the patch or somebody will take it from this email
> thread?

No, unless your mailer mangled the patch I should be able to pull it
from this thread.  However, I'm probably going to let this sit until
early next week on the odd chance that anyone else wants to comment on
the flag choice.  I'll send another reply once I merge the patch.

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
