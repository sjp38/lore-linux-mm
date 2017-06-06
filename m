Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A79D6B02F4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 05:17:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k30so14537312wrc.9
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 02:17:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si30256796edh.179.2017.06.06.02.17.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 02:17:32 -0700 (PDT)
Date: Tue, 6 Jun 2017 11:17:27 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Message-ID: <20170606091726.GF1189@dhcp22.suse.cz>
References: <20170602071818.GA29840@dhcp22.suse.cz>
 <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
 <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
 <201706041758.DGG86904.SOOVLtMJFOQFFH@I-love.SAKURA.ne.jp>
 <20170604150533.GA3500@dhcp22.suse.cz>
 <201706050643.EDD87569.VSFQOFJtFHOOML@I-love.SAKURA.ne.jp>
 <20170605053701.GA9773@dhcp22.suse.cz>
 <CAM_iQpWV_bir4=66o-rpDrEYVt1Ufq3-zi+bG0QQGjTc1V8B=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM_iQpWV_bir4=66o-rpDrEYVt1Ufq3-zi+bG0QQGjTc1V8B=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dave.hansen@intel.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, vbabka@suse.cz

On Mon 05-06-17 11:15:19, Cong Wang wrote:
> On Sun, Jun 4, 2017 at 10:37 PM, Michal Hocko <mhocko@suse.com> wrote:
> > Running a distribution kernel is at risk that obscure bugs (like this
> > one) will be asked to be reproduced on the vanilla kernel. I work to
> > support a distribution kernel as well and I can tell you that I always
> > do my best reproducing or at least pinpointing the issue before
> > reporting it upstream. People working on the upstream kernel are quite
> > busy and _demanding_ a support for something that should come from their
> > vendor is a bit to much.
> 
> I understand that. As I already explained, our kernel has _zero_ code that
> is not in upstream, it is just 4.9.23 plus some non-mm backports from latest.

Yes I understand that. And as this is quite an obscure bug I think it
would be safer to either run with a clean 4.9 stable or the current
linus tree. The later would be preferable because there are some changes
in the mm proper which might or might not be related (e.g. aa187507ef8bb
which throttles a rather talkative warn_alloc_show_mem).

> So my question is, is there any fix you believe that is relevant in linux-next
> but not in 4.9.23? We definitely can try to backport it too. I have checked
> the changelog since 4.9 and don't find anything obviously relevant.
>
> Meanwhile, I will try to run this LTP test repeatly to see if there is any luck.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
