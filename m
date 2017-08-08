Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id F38156B02F3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:34:18 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 65so6333205lfa.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:34:18 -0700 (PDT)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id e86si600773lji.325.2017.08.08.06.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:34:16 -0700 (PDT)
Received: by mail-lf0-x22a.google.com with SMTP id d17so14975425lfe.0
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:34:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170807065827.GC32434@dhcp22.suse.cz>
References: <20170802105018.GA2529@dhcp22.suse.cz> <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
 <20170803081152.GC12521@dhcp22.suse.cz> <5aca0179-3b04-aa1a-58cd-668a04f63ae7@I-love.SAKURA.ne.jp>
 <20170803103337.GH12521@dhcp22.suse.cz> <201708031944.JCB39029.SJOOOLHFQFMVFt@I-love.SAKURA.ne.jp>
 <20170803110548.GK12521@dhcp22.suse.cz> <CAHC9VhQ_TtFPQL76OEui8_rfvDJ5i6AEdPdYLSHtn1vtWEKTOA@mail.gmail.com>
 <20170804075636.GD26029@dhcp22.suse.cz> <CAHC9VhR_SJUg2wkKhoeXHJeLrNFh=KYwSgz-5X57xx0Maa95Mg@mail.gmail.com>
 <20170807065827.GC32434@dhcp22.suse.cz>
From: Paul Moore <paul@paul-moore.com>
Date: Tue, 8 Aug 2017 09:34:15 -0400
Message-ID: <CAHC9VhRGmBn7EA1iLzHjv2A3nawc5ZtZs+cjdVm4BUX0wGGHVA@mail.gmail.com>
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, mgorman@suse.de
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@tycho.nsa.gov

On Mon, Aug 7, 2017 at 2:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 04-08-17 13:12:04, Paul Moore wrote:
>> On Fri, Aug 4, 2017 at 3:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>> > Btw. Should I resend the patch or somebody will take it from this email
>> > thread?
>>
>> No, unless your mailer mangled the patch I should be able to pull it
>> from this thread.  However, I'm probably going to let this sit until
>> early next week on the odd chance that anyone else wants to comment on
>> the flag choice.  I'll send another reply once I merge the patch.
>
> OK, there is certainly no hurry for merging this. Thanks!
> --
> Michal Hocko
> SUSE Labs

Merged into selinux/next with this patch description, and your
sign-off (I had to munge the description a bit based on the thread).
Are you okay with this, especially your sign-off?

  commit 476accbe2f6ef69caeebe99f52a286e12ac35aee
  Author: Michal Hocko <mhocko@kernel.org>
  Date:   Thu Aug 3 10:11:52 2017 +0200

   selinux: use GFP_NOWAIT in the AVC kmem_caches

   There is a strange __GFP_NOMEMALLOC usage pattern in SELinux,
   specifically GFP_ATOMIC | __GFP_NOMEMALLOC which doesn't make much
   sense.  GFP_ATOMIC on its own allows to access memory reserves while
   __GFP_NOMEMALLOC dictates we cannot use memory reserves.  Replace this
   with the much more sane GFP_NOWAIT in the AVC code as we can tolerate
   memory allocation failures in that code.

   Signed-off-by: Michal Hocko <mhocko@kernel.org>
   Acked-by: Mel Gorman <mgorman@suse.de>
   Signed-off-by: Paul Moore <paul@paul-moore.com>

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
