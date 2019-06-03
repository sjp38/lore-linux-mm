Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B2D9C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:19:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFAD826EEC
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:19:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Qe9LZdq8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFAD826EEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D1F76B000C; Mon,  3 Jun 2019 12:19:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85B186B000D; Mon,  3 Jun 2019 12:19:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74AEB6B000E; Mon,  3 Jun 2019 12:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26FAC6B000C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:19:30 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s4so8710428wrn.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:19:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tCvefdLEzZFFnGKYljkJu42dp0wb4UPwJgMz0erD2bs=;
        b=gUa1H3ibTa36miKpqETYdSBQRF3w96pNV8U/Y3iv5LlG8x9p4SCzLQ073iQU49Ghyb
         rB16I3hydrkSvdqSRpADZp9rcJ2t5i0if8JwoeP5/bxpxBN3FJFs9HZpGcklm8yhORxQ
         mV6qL8P3MfT/1VRCiM8Atx/dQBJSvZRpnooelBMR/Epmjk4E/I3+Zzt3+papptCBWrD/
         KoIiz0hW+yzkpL5BzNynj6gansYkWzRPNNQ+eFKQpyA1x+pejLI98eb7XgI3p/Ca4w6g
         PtFYamHUeCgz8j2UYC5B8nav+/2j3XQxp4ZrsoBeZbLgUnZ6IHgVJ7deJLDp43Ph6yR/
         4MQA==
X-Gm-Message-State: APjAAAVIWRpuIAOE3B26IBcYNkEuaouGvnf6+K7766JAfJrYkPI7Zc4X
	sB8I0exULyTds+hH4x3OVNIHw8LvxcxhpW6V+ZAlGOUBkRKcrwRVm45+sr4xtwTM8z6sPWTa1/p
	Ps4hlok1i6FM8ACdxQwkMFGoW2Zs5rZQg29Kp4YvM0piv8s9O9PHv67AXIg5B9sASgw==
X-Received: by 2002:a1c:e715:: with SMTP id e21mr3003942wmh.16.1559578769720;
        Mon, 03 Jun 2019 09:19:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrth6Btb5jKXxFHxdkrYGi5xmxI+hZEqYR7OoiLD0dy8zAvnAJ+KZaaqbt+PpeCED2KE9l
X-Received: by 2002:a1c:e715:: with SMTP id e21mr3003900wmh.16.1559578768783;
        Mon, 03 Jun 2019 09:19:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559578768; cv=none;
        d=google.com; s=arc-20160816;
        b=IKU1GztrdNvKi6xHyGct1pASXaRR2Um2imlibt008e4biaC2FOland6AhGt3Ow9k7t
         Vxe3G5NfexKp7dj8XYeETM1pp2KBZWobdGNhb08AZ2XsmmHgymSqILW1hYPBRkkEvs6z
         jiulkK0TEEGj0m3+CgQChMNc+Tmd8xeEF0LeASpmWv16KY+gp6TN0LOw3/+UdFp/7+v1
         no+sMD5Yd6NqApbtSJc3YPhIXzcQjR3qe+kzuzUdAOUT1PxNwg6P3UpGMXoJYCEK+Njw
         1o5rWtSJqZbINsiNORrMsYX+gjiu2SurKXt2awU7of+P2etvIUP5TwV4UDUQVFmey2ln
         VNog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tCvefdLEzZFFnGKYljkJu42dp0wb4UPwJgMz0erD2bs=;
        b=LrYL3RR5IYi5A1Ab+Na7vqbQeqz5hzkf11ZO4Cv09gzo9ZXgdDYBg7ZoH5NqQz9tqK
         ZHSuZv3XDRtgs0YNlpJSkpPADMLFXsOCHNvGFY4ejfg6fxLMHYIIMI0GlxovXPwI65yo
         ixS1Cn/OaEvKlYCvyt0qiJB9U8ARRLtWfRgjRZi7FtRlMfwaCwDhpvNJsHzxKtGuoU1S
         UxDpXCuURve1rASvgG3ArXDAK4+u21n2xjRJUGNiJQpvnz2Zo+5hsEb0ejQiJimi5oTt
         OH5b4oZO9bXou+AgC9TF5ZjNUFaLpgCJOC8bhjSg05Fv4auFRKpLpjiPjdXLktWn7FYJ
         ab8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Qe9LZdq8;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t5si9503094wrn.419.2019.06.03.09.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 09:19:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Qe9LZdq8;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tCvefdLEzZFFnGKYljkJu42dp0wb4UPwJgMz0erD2bs=; b=Qe9LZdq8JvV4H1j8BClRr1eIY
	na0qS+QFSOpMiGx+KxMA4vjS7StYq/Be2T6RY6jWR8BInYLDVsZ5wxrGNy4JHPymgxGIHrNahM/VZ
	Rgr3V+kcOH+6MW6GM4NyKla3IC/7PpC5twZdB1NX0hd5un1ZnkVpxEZeeKmLaiZKf5llwbmqKXkHb
	4vr7kMDuvOYH9bBRsWEyzpH7GHJqzTO8FQd3qF3Gm0UALv15ZsIsKiZQxOk7AjDULqTthckovZpl/
	G/UH7fvmBINUynoswkPEb+rLvq1IFVpICsvh3hlaNCoNuil7UKKGqrmGHrCyTy8UIc8wFr4vNBP5U
	csHxhzQCg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXpgC-0004Uf-0H; Mon, 03 Jun 2019 16:19:24 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 7C40529BBD36C; Mon,  3 Jun 2019 18:19:22 +0200 (CEST)
Date: Mon, 3 Jun 2019 18:19:22 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, hch@lst.de, gkohli@codeaurora.org,
	mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190603161922.GB3402@hirez.programming.kicks-ass.net>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <20190603124401.GB3463@hirez.programming.kicks-ass.net>
 <20190603160953.GA15244@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190603160953.GA15244@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:09:53PM +0200, Oleg Nesterov wrote:
> On 06/03, Peter Zijlstra wrote:
> >
> > It now also has concurrency on wakeup; but afaict that's harmless, we'll
> > get racing stores of p->state = TASK_RUNNING, much the same as if there
> > was a remote wakeup vs a wait-loop terminating early.
> >
> > I suppose the tracepoint consumers might have to deal with some
> > artifacts there, but that's their problem.
> 
> I guess you mean that trace_sched_waking/wakeup can be reported twice if
> try_to_wake_up(current) races with ttwu_remote(). And ttwu_stat().

Right, one local one remote, and you get them things twice.

> > > --- a/kernel/sched/core.c
> > > +++ b/kernel/sched/core.c
> > > @@ -1990,6 +1990,28 @@ try_to_wake_up(struct task_struct *p, unsigned int state, int wake_flags)
> > >  	unsigned long flags;
> > >  	int cpu, success = 0;
> > >  
> > > +	if (p == current) {
> > > +		/*
> > > +		 * We're waking current, this means 'p->on_rq' and 'task_cpu(p)
> > > +		 * == smp_processor_id()'. Together this means we can special
> > > +		 * case the whole 'p->on_rq && ttwu_remote()' case below
> > > +		 * without taking any locks.
> > > +		 *
> > > +		 * In particular:
> > > +		 *  - we rely on Program-Order guarantees for all the ordering,
> > > +		 *  - we're serialized against set_special_state() by virtue of
> > > +		 *    it disabling IRQs (this allows not taking ->pi_lock).
> > > +		 */
> > > +		if (!(p->state & state))
> > > +			goto out;
> > > +
> > > +		success = 1;
> > > +		trace_sched_waking(p);
> > > +		p->state = TASK_RUNNING;
> > > +		trace_sched_woken(p);
>                 ^^^^^^^^^^^^^^^^^
> trace_sched_wakeup(p) ?

Uhm,, yah.

> I see nothing wrong... but probably this is because I don't fully understand
> this change. In particular, I don't really understand who else can benefit from
> this optimization...

Pretty much every wait-loop, where the wakeup happens from IRQ context
on the same CPU, before we've hit schedule().

Now, I've no idea if that's many, but I much prefer to keep this magic
inside try_to_wake_up() than spreading it around.

