Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFFD7C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:11:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71B732146F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:11:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="LFBHGgqx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71B732146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2145C6B0269; Thu, 11 Apr 2019 17:11:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C4BB6B026B; Thu, 11 Apr 2019 17:11:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B45F6B026C; Thu, 11 Apr 2019 17:11:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C60606B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:11:04 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so4990487pfl.16
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:11:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=I+PugfY7FgqqWZlX12lcfitAcnPLuri4PjNmIYu5QC0=;
        b=N35EaD8UsuDNLKCka+tzxStXFe0TA91ajpeBGL+Di+ruPUcDd3IIPiOwKrhUaSV0nD
         0hvE6QsUKQ/6/jr2LnsaQ4txxBqNxWHMScnaAIeaOfu9wZpi5bv2RYKk6IvyKYdE7rMd
         hQU7cN0N0l+5I6cXr/95XJQxqIgYibFXHr54BEqEMkF2WOGTFO0/UPxSm1C9eyUn9/NH
         EtlfProIqXBKS9UpdFjIQv6gQ5t1qD/IXNdSg7GHFGhDVDODuUUgzmCyEyCkfIZb0AGa
         SgCVQvD4TQfX3oJ0bnMmpYenXY/U/CWlzfclshz8r50iU5tO2MasT724OmKeLZnXWfEe
         IISw==
X-Gm-Message-State: APjAAAUkr8wT1ZBogPJXDJMvwv1gnWVEl8m7qbnHumfcxVlxCBRVFoR5
	eu/WVhdKUmcX130B8cik/nXmRoGdTE9wixtEPEZ995ZZ06W4G+pXeYL46RXWxRYr5fTHvLEAV2O
	NYRANaihfI04UPRJmqUAAAR6+MWNJ1wREIqa5CNzEd10+vCzzFKqo9RdgERlU+ImP+Q==
X-Received: by 2002:a62:fb0a:: with SMTP id x10mr52804878pfm.179.1555017063950;
        Thu, 11 Apr 2019 14:11:03 -0700 (PDT)
X-Received: by 2002:a62:fb0a:: with SMTP id x10mr52804799pfm.179.1555017063037;
        Thu, 11 Apr 2019 14:11:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555017063; cv=none;
        d=google.com; s=arc-20160816;
        b=Hy2G8R+QogHhdMEXtuAUxKdqBwX3+2Yagsppr2jYzQIHst+Mwq0KnOHpVWs0D4DKMZ
         w2aRbSbJsh4gsyP1+Q06Au3kXPqslYUiwJL7oAjTFPZcAcO7O4JZ2tLYb4tn1BgCO2JF
         +J+6yt3BHe+NNqgEGwi1ygVZXMIS5j/cgUGAO5tSKtfhZFQwdw8OBPAFt1a4b3q6PlNo
         QrbFijh7orMRKN2JXkVudGAevz7EG9myOhsu/NJJXNM2fVuLkDarCTzwnW9wJbtBCEqN
         MSJCQ2CP+8+BbJZZ8n8+o7J3fENr2yCE1Ttci12kvzUK1drvy8un2IRYe1isZ22KO/hY
         YZag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=I+PugfY7FgqqWZlX12lcfitAcnPLuri4PjNmIYu5QC0=;
        b=FmEbauhgdy/7a/YIw8+4coZXaB/uGyIGUHntZRWg7PP95uuBD4uROKuyPkvMU7p+iz
         /WFUDrCW0jCKYzqYmEJDXTeQ6c4m0tLrhjzhJ46HzL6oWB3tnuejDVSzN4uUlgG79O3a
         wFUAA1Pu1u7G7HTqSePXsTE66R/r/Lj4BA2sBmnp4yGqv+DofEsfCtQTUm8X3kKh8R9F
         LE5qd751b+lPkAKHgqD5/sgPR/DgTVuBLPxVwhhxHSYt0HRj8RB12+84NQmgchGbgLFx
         cBNwfNy/84Z5gAVTbLJOjw2wfFjjQafBQ0TL/8yqP3oWevOu98+BS4/kPd1RPlGmCNwB
         yljA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=LFBHGgqx;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor40559474pfi.67.2019.04.11.14.11.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 14:11:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=LFBHGgqx;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=I+PugfY7FgqqWZlX12lcfitAcnPLuri4PjNmIYu5QC0=;
        b=LFBHGgqxaNhM1QkYzfgVAiZNPyPSnPApVPKSjqfzAskaEthnehAuBAC/cJ+VOv3hkG
         zloQJPtt3vojCn51Tud33Z3AD0JyHW4sUB/rdW8EDqKykODjSGjxCScS70wKtsQQoIoO
         eaNctJ67Ms/J+woOhqLxKhBFfRtN/0NGQ7eqc=
X-Google-Smtp-Source: APXvYqzKotygSk0Un81n8ndkReO8MzVRYC2KJpHXIj5+6OIFGorhASRNEQDfIyC8G4Ox/UkAP8a1mg==
X-Received: by 2002:a62:26c1:: with SMTP id m184mr14958505pfm.102.1555017062281;
        Thu, 11 Apr 2019 14:11:02 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id p7sm71208945pfp.70.2019.04.11.14.11.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 14:11:01 -0700 (PDT)
Date: Thu, 11 Apr 2019 17:11:00 -0400
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
Message-ID: <20190411211100.GB130334@google.com>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411105111.GR10383@dhcp22.suse.cz>
 <CAJWu+oq45tYxXJpLPLAU=-uZaYRg=OnxMHkgp2Rm0nbShb_eEA@mail.gmail.com>
 <20190411181243.GB10383@dhcp22.suse.cz>
 <20190411191430.GA46425@google.com>
 <20190411201151.GA4743@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411201151.GA4743@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:11:51PM +0200, Michal Hocko wrote:
> On Thu 11-04-19 15:14:30, Joel Fernandes wrote:
> > On Thu, Apr 11, 2019 at 08:12:43PM +0200, Michal Hocko wrote:
> > > On Thu 11-04-19 12:18:33, Joel Fernandes wrote:
> > > > On Thu, Apr 11, 2019 at 6:51 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> > > > > [...]
> > > > > > Proposed solution uses existing oom-reaper thread to increase memory
> > > > > > reclaim rate of a killed process and to make this rate more deterministic.
> > > > > > By no means the proposed solution is considered the best and was chosen
> > > > > > because it was simple to implement and allowed for test data collection.
> > > > > > The downside of this solution is that it requires additional “expedite”
> > > > > > hint for something which has to be fast in all cases. Would be great to
> > > > > > find a way that does not require additional hints.
> > > > >
> > > > > I have to say I do not like this much. It is abusing an implementation
> > > > > detail of the OOM implementation and makes it an official API. Also
> > > > > there are some non trivial assumptions to be fullfilled to use the
> > > > > current oom_reaper. First of all all the process groups that share the
> > > > > address space have to be killed. How do you want to guarantee/implement
> > > > > that with a simply kill to a thread/process group?
> > > > 
> > > > Will task_will_free_mem() not bail out in such cases because of
> > > > process_shares_mm() returning true?
> > > 
> > > I am not really sure I understand your question. task_will_free_mem is
> > > just a shortcut to not kill anything if the current process or a victim
> > > is already dying and likely to free memory without killing or spamming
> > > the log. My concern is that this patch allows to invoke the reaper
> > 
> > Got it.
> > 
> > > without guaranteeing the same. So it can only be an optimistic attempt
> > > and then I am wondering how reasonable of an interface this really is.
> > > Userspace send the signal and has no way to find out whether the async
> > > reaping has been scheduled or not.
> > 
> > Could you clarify more what you're asking to guarantee? I cannot picture it.
> > If you mean guaranteeing that "a task is dying anyway and will free its
> > memory on its own", we are calling task_will_free_mem() to check that before
> > invoking the oom reaper.
> 
> No, I am talking about the API aspect. Say you kall kill with the flag
> to make the async address space tear down. Now you cannot really
> guarantee that this is safe to do because the target task might
> clone(CLONE_VM) at any time. So this will be known only once the signal
> is sent, but the calling process has no way to find out. So the caller
> has no way to know what is the actual result of the requested operation.
> That is a poor API in my book.
> 
> > Could you clarify what is the draback if OOM reaper is invoked in parallel to
> > an exiting task which will free its memory soon? It looks like the OOM reaper
> > is taking all the locks necessary (mmap_sem) in particular and is unmapping
> > pages. It seemed to me to be safe, but I am missing what are the main draw
> > backs of this - other than the intereference with core dump. One could be
> > presumably scalability since the since OOM reaper could be bottlenecked by
> > freeing memory on behalf of potentially several dying tasks.
> 
> oom_reaper or any other kernel thread doing the same is a mere
> implementation detail I think. The oom killer doesn't really need the
> oom_reaper to act swiftly because it is there to act as a last resort if
> the oom victim cannot terminate on its own. If you want to offer an
> user space API then you can assume users will like to use it and expect
> a certain behavior but what that is? E.g. what if there are thousands of
> tasks killed this way? Do we care that some of them will not get the
> async treatment? If yes why do we need an API to control that at all?
> 
> Am I more clear now?

Yes, your concerns are more clear now. We will think more about this and your
other responses, thanks a lot.

 - Joel

