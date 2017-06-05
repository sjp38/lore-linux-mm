Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 075826B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 14:15:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so24298314wmc.8
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 11:15:41 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id 1si23858503wrq.16.2017.06.05.11.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 11:15:40 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id x70so19230850wme.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 11:15:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170605053701.GA9773@dhcp22.suse.cz>
References: <20170602071818.GA29840@dhcp22.suse.cz> <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
 <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
 <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
 <20170604150533.GA3500@dhcp22.suse.cz> <201706050643.EDD87569.VSFQOFJtFHOOML@I-love.SAKURA.ne.jp>
 <20170605053701.GA9773@dhcp22.suse.cz>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 5 Jun 2017 11:15:19 -0700
Message-ID: <CAM_iQpWV_bir4=66o-rpDrEYVt1Ufq3-zi+bG0QQGjTc1V8B=A@mail.gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dave.hansen@intel.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, vbabka@suse.cz

On Sun, Jun 4, 2017 at 10:37 PM, Michal Hocko <mhocko@suse.com> wrote:
> Running a distribution kernel is at risk that obscure bugs (like this
> one) will be asked to be reproduced on the vanilla kernel. I work to
> support a distribution kernel as well and I can tell you that I always
> do my best reproducing or at least pinpointing the issue before
> reporting it upstream. People working on the upstream kernel are quite
> busy and _demanding_ a support for something that should come from their
> vendor is a bit to much.

I understand that. As I already explained, our kernel has _zero_ code that
is not in upstream, it is just 4.9.23 plus some non-mm backports from latest.

So my question is, is there any fix you believe that is relevant in linux-next
but not in 4.9.23? We definitely can try to backport it too. I have checked
the changelog since 4.9 and don't find anything obviously relevant.

Meanwhile, I will try to run this LTP test repeatly to see if there is any luck.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
