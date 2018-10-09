Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D675E6B0005
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 07:10:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c26-v6so1030620eda.7
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 04:10:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i31-v6si1667013edc.211.2018.10.09.04.10.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 04:10:07 -0700 (PDT)
Date: Tue, 9 Oct 2018 13:10:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
Message-ID: <20181009111005.GK8528@dhcp22.suse.cz>
References: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
 <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
 <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
 <20181009063541.GB8528@dhcp22.suse.cz>
 <20181009075015.GC8528@dhcp22.suse.cz>
 <df4b029c-16b4-755f-2672-d7ec116f78ba@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df4b029c-16b4-755f-2672-d7ec116f78ba@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 09-10-18 19:00:44, Tetsuo Handa wrote:
> On 2018/10/09 16:50, Michal Hocko wrote:
[...]
> >                               Well, that is unfortunate indeed and it
> > breaks the OOM_SCORE_ADJ_MIN contract. There are basically two ways here
> > 1) do not care and encourage users to use a saner way to set
> > OOM_SCORE_ADJ_MIN because doing that externally is racy anyway e.g.
> > setting it before [v]fork & exec. Btw. do we know about an actual user
> > who would care?
> 
> I'm not talking about [v]fork & exec. Why are you talking about [v]fork & exec ?

Because that is the only raceless way to set your oom_score_adj.

> > 2) add OOM_SCORE_ADJ_MIN and do not kill tasks sharing mm and do not
> > reap the mm in the rare case of the race.
> 
> That is no problem. The mistake we made in 4.6 was that we updated oom_score_adj
> to -1000 (and allowed unprivileged users to OOM-lockup the system).

I do not follow.

-- 
Michal Hocko
SUSE Labs
