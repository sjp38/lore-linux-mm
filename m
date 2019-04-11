Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69946C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B5BB2173C
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 19:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="ia3huphr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B5BB2173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5C726B0269; Thu, 11 Apr 2019 15:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E4576B026A; Thu, 11 Apr 2019 15:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8869D6B026B; Thu, 11 Apr 2019 15:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 496066B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 15:14:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j184so4966934pgd.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:14:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jbC8xetEJpz5qCoylXvogaDQzUVgXMuKyGOB5cXC308=;
        b=cshMS7UvBaeiYmvzm6oSPUalddRalD9zA3RN16m9Br8yrF8hk/tGFtR/mhjfJdMBvT
         wQ6u2ju5MPvQFTo9IxA4dTN+RQOf4J1Afh/I3OveGFq/DspvbFcuVuVVGBAyT8Bg0L/C
         vwEvcEgk79d+APsnmeHfuFWtWk1TDHafqd1zz+EIMvemB0Io6LrquBgsl7qx9yS9Yag4
         RL8KqjhVvajQPzfeRu9lF5RJND6RBQTGlIYbNdk6ba1TN/DyDNdW3BufDoC67vbo8QtD
         B3frH44eHs+WXBwGDgqY770STXxerigB2/9LTD1XZcFwU8iIWZCDn/jqxy9BbohKImZr
         pBWw==
X-Gm-Message-State: APjAAAUwa3eoyGh6HIVBHcfLjnsSM3ph0CGoY2JU36YlZFPKQ4XjtKWN
	48rcsrR8OkbeuoANRdbi4ywP7nhD7KuK0S0xFdu6snDdD1DxTfQfBk+NHrkm3nd06N96mFU481F
	gvNJryVAUJcUFHEZ+U8MsEM2c9u1CEZuHOwBgrcQwvmvnp+nShsf1VA7asW0FwHBZfg==
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr52492985plb.22.1555010075673;
        Thu, 11 Apr 2019 12:14:35 -0700 (PDT)
X-Received: by 2002:a17:902:2a29:: with SMTP id i38mr52492899plb.22.1555010074628;
        Thu, 11 Apr 2019 12:14:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555010074; cv=none;
        d=google.com; s=arc-20160816;
        b=B1UFygtLQQ32O6pgw/nQNdyY9SXRIXEimhncMPgeT9o9pUjJHItq/cLhbGEpPhrCIK
         yO6/nCt0t/03EqOMhXUIbG3og6/tJHijB1fKaU5kv6OW/b1JOJbWi0xBGihcGNsGNCMa
         7NZMFKiP9OSqQALPHiuAlk8ld4GYUHecvTBGZeoawCYZPSObLKrtaajTrsK6wk3N4xQn
         eqLFoBb7evSEcCuP39z++K+B7ui7Ny5Od3p8qSH1mmcsEJf+eH+BOBp0Vwxm/rlp3VJn
         hBltghDCTkTbzXEJOLitKSDc0GjeLBRvsOOUe44XGWocHTRLnEb1BZyQ6vTkGw4VKmae
         9fZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=jbC8xetEJpz5qCoylXvogaDQzUVgXMuKyGOB5cXC308=;
        b=Rb0c9SW3xLdKDatQvqN7dEK7RHRf63bUGQ1S4RySYf4eDS5KGXdaNcdMhulBSBki89
         8PuZgfxDtHUNNGv/aLF6fbPBbS88dkiwuaNQQNoRHAazoNBHsWu6LKu68jA61bQENOlX
         L47bIWqW5MhdoiR9stlkKq7Ukw9MVt0EgtFVt39u1sm+3W9C14LKa2NhkmLzR76ePjHf
         oTTFIkKjojzvOah+aSbaLxY/z5bYqzVvQBLQd/k9x+NbcwLv4GixFDcAORGeIHW2I7Oe
         A+bfzkYeiCf5OP1NwAg08eCjkTYtyl3af/WSyDMAsR4681wB71AGuycLYuPpTJIEUCVC
         nMkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=ia3huphr;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r32sor43162099pgb.74.2019.04.11.12.14.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 12:14:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=ia3huphr;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=jbC8xetEJpz5qCoylXvogaDQzUVgXMuKyGOB5cXC308=;
        b=ia3huphrOspf9u8RIw/c+ODureqTkw0avu8oKPFJ61uPtSePwnPonhu3vg3z33sVMg
         qsRgemWEItRmseDsDpEqpbvu/il0c7GaqwOFdwMMqls2+xLTWFPuOK4wigUnBbWVbSkL
         SLYBloSZALOpR2IqP1vI/TvWD+4paNjDsUkRE=
X-Google-Smtp-Source: APXvYqwDRYJr8j+3gj9Y7YLUM5aUAcJ0bISd6C8+u+eZPyWPILU4906GJsYaezHtsWzaFxOGw/0fRA==
X-Received: by 2002:a63:7153:: with SMTP id b19mr46989049pgn.289.1555010073275;
        Thu, 11 Apr 2019 12:14:33 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id w3sm82743762pfn.179.2019.04.11.12.14.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 12:14:32 -0700 (PDT)
Date: Thu, 11 Apr 2019 15:14:30 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	penguin-kernel@i-love.sakura.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Daniel Colascione <dancol@google.com>, Jann Horn <jannh@google.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Cc: Android Kernel" <kernel-team@android.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
Message-ID: <20190411191430.GA46425@google.com>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJWu+oq45tYxXJpLPLAU=-uZaYRg=OnxMHkgp2Rm0nbShb_eEA@mail.gmail.com>
 <20190411181243.GB10383@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411181243.GB10383@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 08:12:43PM +0200, Michal Hocko wrote:
> On Thu 11-04-19 12:18:33, Joel Fernandes wrote:
> > On Thu, Apr 11, 2019 at 6:51 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> > > [...]
> > > > Proposed solution uses existing oom-reaper thread to increase memory
> > > > reclaim rate of a killed process and to make this rate more deterministic.
> > > > By no means the proposed solution is considered the best and was chosen
> > > > because it was simple to implement and allowed for test data collection.
> > > > The downside of this solution is that it requires additional “expedite”
> > > > hint for something which has to be fast in all cases. Would be great to
> > > > find a way that does not require additional hints.
> > >
> > > I have to say I do not like this much. It is abusing an implementation
> > > detail of the OOM implementation and makes it an official API. Also
> > > there are some non trivial assumptions to be fullfilled to use the
> > > current oom_reaper. First of all all the process groups that share the
> > > address space have to be killed. How do you want to guarantee/implement
> > > that with a simply kill to a thread/process group?
> > 
> > Will task_will_free_mem() not bail out in such cases because of
> > process_shares_mm() returning true?
> 
> I am not really sure I understand your question. task_will_free_mem is
> just a shortcut to not kill anything if the current process or a victim
> is already dying and likely to free memory without killing or spamming
> the log. My concern is that this patch allows to invoke the reaper

Got it.

> without guaranteeing the same. So it can only be an optimistic attempt
> and then I am wondering how reasonable of an interface this really is.
> Userspace send the signal and has no way to find out whether the async
> reaping has been scheduled or not.

Could you clarify more what you're asking to guarantee? I cannot picture it.
If you mean guaranteeing that "a task is dying anyway and will free its
memory on its own", we are calling task_will_free_mem() to check that before
invoking the oom reaper.

Could you clarify what is the draback if OOM reaper is invoked in parallel to
an exiting task which will free its memory soon? It looks like the OOM reaper
is taking all the locks necessary (mmap_sem) in particular and is unmapping
pages. It seemed to me to be safe, but I am missing what are the main draw
backs of this - other than the intereference with core dump. One could be
presumably scalability since the since OOM reaper could be bottlenecked by
freeing memory on behalf of potentially several dying tasks.

IIRC this patch is just Ok with being opportunistic and it need not be hidden
behind an API necessarily or need any guarantees. It is just providing a hint
that the OOM reaper could be woken up to expedite things. If a task is going
to be taking a long time to be scheduled and free its memory, the oom reaper
gives a headstart.  Many of the times, background tasks can be killed but
they may not have necessarily sufficient scheduler priority / cpuset (being
in the background) and may be holding onto a lot of memory that needs to be
reclaimed.

I am not saying this the right way to do it, but I also wanted us to
understand the drawbacks so that we can go back to the drawing board and come
up with something better.

Thanks!

 - Joel




