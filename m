Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8FC76B038A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 21:04:18 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 65so59917747oig.3
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 18:04:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x1si23728428pfa.171.2017.02.21.18.04.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 18:04:17 -0800 (PST)
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170202101415.GE22806@dhcp22.suse.cz>
	<201702031957.AGH86961.MLtOQVFOSHJFFO@I-love.SAKURA.ne.jp>
	<20170221094034.GF15595@dhcp22.suse.cz>
	<201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp>
	<20170221155337.GK15595@dhcp22.suse.cz>
In-Reply-To: <20170221155337.GK15595@dhcp22.suse.cz>
Message-Id: <201702221102.EHH69234.OQLOMFSOtJFVHF@I-love.SAKURA.ne.jp>
Date: Wed, 22 Feb 2017 11:02:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: david@fromorbit.com, dchinner@redhat.com, hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Tue 21-02-17 23:35:07, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > OK, so it seems that all the distractions are handled now and linux-next
> > > should provide a reasonable base for testing. You said you weren't able
> > > to reproduce the original long stalls on too_many_isolated(). I would be
> > > still interested to see those oom reports and potential anomalies in the
> > > isolated counts before I send the patch for inclusion so your further
> > > testing would be more than appreciated. Also stalls > 10s without any
> > > previous occurrences would be interesting.
> > 
> > I confirmed that linux-next-20170221 with kmallocwd applied can reproduce
> > infinite too_many_isolated() loop problem. Please send your patches to linux-next.
> 
> So I assume that you didn't see the lockup with the patch applied and
> the OOM killer has resolved the situation by killing other tasks, right?
> Can I assume your Tested-by?

No. I tested linux-next-20170221 which does not include your patch.
I didn't test linux-next-20170221 with your patch applied. Your patch will
avoid infinite too_many_isolated() loop problem in shrink_inactive_list().
But we need to test different workloads by other people. Thus, I suggest
you to send your patches to linux-next without my testing.

> 
> Thanks for your testing!
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
