Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B51336B03AC
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 10:53:40 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so16867205wmg.4
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 07:53:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b65si16935568wmd.35.2017.02.21.07.53.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 07:53:39 -0800 (PST)
Date: Tue, 21 Feb 2017 16:53:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170221155337.GK15595@dhcp22.suse.cz>
References: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
 <20170130085546.GF8443@dhcp22.suse.cz>
 <20170202101415.GE22806@dhcp22.suse.cz>
 <201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
 <20170221094034.GF15595@dhcp22.suse.cz>
 <201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Tue 21-02-17 23:35:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > OK, so it seems that all the distractions are handled now and linux-next
> > should provide a reasonable base for testing. You said you weren't able
> > to reproduce the original long stalls on too_many_isolated(). I would be
> > still interested to see those oom reports and potential anomalies in the
> > isolated counts before I send the patch for inclusion so your further
> > testing would be more than appreciated. Also stalls > 10s without any
> > previous occurrences would be interesting.
> 
> I confirmed that linux-next-20170221 with kmallocwd applied can reproduce
> infinite too_many_isolated() loop problem. Please send your patches to linux-next.

So I assume that you didn't see the lockup with the patch applied and
the OOM killer has resolved the situation by killing other tasks, right?
Can I assume your Tested-by?

Thanks for your testing!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
