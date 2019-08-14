Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33ADBC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:32:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECC7F214C6
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 16:32:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="RnBh7I01"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECC7F214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B0066B0003; Wed, 14 Aug 2019 12:32:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 836496B0005; Wed, 14 Aug 2019 12:32:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D7116B000A; Wed, 14 Aug 2019 12:32:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0027.hostedemail.com [216.40.44.27])
	by kanga.kvack.org (Postfix) with ESMTP id 42E146B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 12:32:08 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E0C854FE2
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:32:07 +0000 (UTC)
X-FDA: 75821575494.08.park94_2fa207e7a5304
X-HE-Tag: park94_2fa207e7a5304
X-Filterd-Recvd-Size: 7681
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:32:07 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id a93so50863969pla.7
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 09:32:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=JW7NJ2x8aCYJgh9Quu4m2Xy6h4AMn4oD9DcUlwK+nlA=;
        b=RnBh7I01/H1DbTynCmuURc8VbMF7+q40o0fbix1RneZMmFzklD3vG3O010YUou1qzr
         xgDCJtHMH/tZntjjAeYmLfFj3G6gKPLWnQnMVapQQcNVGDb2UBOMic/vN+kl/T1f3hpI
         6jlqwgKsplgqpmo7KxuSiGH/I6rDpu/yLQ17E=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=JW7NJ2x8aCYJgh9Quu4m2Xy6h4AMn4oD9DcUlwK+nlA=;
        b=sXhKvmjRw3EOsO0uDbNuzFGK1gzxSIC5aZHsPE22ifyT4zeIGOhHBaiMunbT9WShw2
         STCparlpSQCWjnPYBIerCe0RSYeJys9kam3wyAchnr4IVYQn3oNEmr2FvsYpeYJi8z8X
         aHlu331peTdGinaPDnVbJNDCxO6O6e3GoJhcKC1IAcPUT/UWWKQobuoiIoqSsGTSZd/9
         8bTC3pQU6FTdRtXXkh9bHgERMOjgc38hnDa/gSQNBhAfjQ46EFTHfe1svJmK1SwzrsZE
         nfOF0T1k1iq04jeCi4UL0pGm6dozkmaMXofdX92q6d1U0Gxp5CW11Nf/Y+5uf3sDqSno
         WFEA==
X-Gm-Message-State: APjAAAVNm59Csc++WiQUrWT2vVd+ahgJ0tKSGyAQIABV/R9GsKcM5myp
	pOnR8f2ekT/zkuv+O2nqruZx5w==
X-Google-Smtp-Source: APXvYqyNmLGFG4L6ESKyb+mVrWkKxNJARdOlA2tR89i2oE4Rl4NOl56mfPIJHkJQ8RneB/DaFT2yCg==
X-Received: by 2002:a17:902:169:: with SMTP id 96mr219508plb.297.1565800325785;
        Wed, 14 Aug 2019 09:32:05 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id t7sm290486pjq.15.2019.08.14.09.32.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 09:32:04 -0700 (PDT)
Date: Wed, 14 Aug 2019 12:32:03 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: khlebnikov@yandex-team.ru, linux-kernel@vger.kernel.org,
	Minchan Kim <minchan@kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Christian Hansen <chansen3@cisco.com>, dancol@google.com,
	fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
	Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>, kernel-team@android.com,
	linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Mike Rapoport <rppt@linux.ibm.com>, namhyung@google.com,
	paulmck@linux.ibm.com, Robin Murphy <robin.murphy@arm.com>,
	Roman Gushchin <guro@fb.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, surenb@google.com,
	Thomas Gleixner <tglx@linutronix.de>, tkjos@google.com,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will@kernel.org>
Subject: Re: [PATCH v5 2/6] mm/page_idle: Add support for handling swapped
 PG_Idle pages
Message-ID: <20190814163203.GB59398@google.com>
References: <20190807171559.182301-1-joel@joelfernandes.org>
 <20190807171559.182301-2-joel@joelfernandes.org>
 <20190813150450.GN17933@dhcp22.suse.cz>
 <20190813153659.GD14622@google.com>
 <20190814080531.GP17933@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814080531.GP17933@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:05:31AM +0200, Michal Hocko wrote:
> On Tue 13-08-19 11:36:59, Joel Fernandes wrote:
> > On Tue, Aug 13, 2019 at 05:04:50PM +0200, Michal Hocko wrote:
> > > On Wed 07-08-19 13:15:55, Joel Fernandes (Google) wrote:
> > > > Idle page tracking currently does not work well in the following
> > > > scenario:
> > > >  1. mark page-A idle which was present at that time.
> > > >  2. run workload
> > > >  3. page-A is not touched by workload
> > > >  4. *sudden* memory pressure happen so finally page A is finally swapped out
> > > >  5. now see the page A - it appears as if it was accessed (pte unmapped
> > > >     so idle bit not set in output) - but it's incorrect.
> > > > 
> > > > To fix this, we store the idle information into a new idle bit of the
> > > > swap PTE during swapping of anonymous pages.
> > > >
> > > > Also in the future, madvise extensions will allow a system process
> > > > manager (like Android's ActivityManager) to swap pages out of a process
> > > > that it knows will be cold. To an external process like a heap profiler
> > > > that is doing idle tracking on another process, this procedure will
> > > > interfere with the idle page tracking similar to the above steps.
> > > 
> > > This could be solved by checking the !present/swapped out pages
> > > right? Whoever decided to put the page out to the swap just made it
> > > idle effectively.  So the monitor can make some educated guess for
> > > tracking. If that is fundamentally not possible then please describe
> > > why.
> > 
> > But the monitoring process (profiler) does not have control over the 'whoever
> > made it effectively idle' process.
> 
> Why does that matter? Whether it is a global/memcg reclaim or somebody
> calling MADV_PAGEOUT or whatever it is a decision to make the page not
> hot. Sure you could argue that a missing idle bit on swap entries might
> mean that the swap out decision was pre-mature/sub-optimal/wrong but is
> this the aim of the interface?
> 
> > As you said it will be a guess, it will not be accurate.
> 
> Yes and the point I am trying to make is that having some space and not
> giving a guarantee sounds like a safer option for this interface because

I do see your point of view, but jJust because a future (and possibly not
going to happen) usecase which you mentioned as pte reclaim, makes you feel
that userspace may be subject to inaccuracies anyway, doesn't mean we should
make everything inaccurate..  We already know idle page tracking is not
completely accurate. But that doesn't mean we miss out on the opportunity to
make the "non pte-reclaim" usecase inaccurate as well. 

IMO, we should do our best for today, and not hypothesize. How likely is pte
reclaim and is there a thread to describe that direction?

> > I am curious what is your concern with using a bit in the swap PTE?
> 
> ... It is a promiss of the semantic I find limiting for future. The bit
> in the pte might turn out insufficient (e.g. pte reclaim) so teaching
> the userspace to consider this a hard guarantee is a ticket to problems
> later on. Maybe I am overly paranoid because I have seen so many "nice
> to have" features turning into a maintenance burden in the past.
> 
> If this is really considered mostly debugging purpouse interface then a
> certain level of imprecision should be tolerateable. If there is a
> really strong real world usecase that simply has no other way to go
> then this might be added later. Adding an information is always safer
> than take it away.
> 
> That being said, if I am a minority voice here then I will not really
> stand in the way and won't nack the patch. I will not ack it neither
> though.

Ok.

thanks,

 - Joel


