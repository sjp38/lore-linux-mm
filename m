Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D6D5C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:37:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E85012084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TvJqi5e5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E85012084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721D56B026D; Thu, 11 Apr 2019 13:37:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D0366B026E; Thu, 11 Apr 2019 13:37:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BEF16B026F; Thu, 11 Apr 2019 13:37:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24BBF6B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:37:09 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id cs14so4523441plb.5
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:37:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=8lPWfr/fv9Mq3ZVmlINx7ayfGTvu31L2DN7bGB7z/yA=;
        b=cyJ7R6bzm0jUk5Mzub+pcIDNJ4hVC8X8dkjTpYkUx0aPu0IxeIcaJ78sMh7C+yHS46
         nUAhM/8I3yGXyyokix8IzPyyGNsMxNLFfu46+8iSPT1AxcXL+xc1K+foeUkPt/FPkWPp
         A8xHkxWERGcNkrSTf4NJnTKXjmauPWsZC6y5jrJQ9HZaU/Nw5S4DNsZHVCU5aiKGZbTv
         sYlVP2WXfcRqUk10n1kYwhIDF398gyatqSW2lIn7pm2VJObDfl4OfcnkwEoc8npvl3nC
         6c/L1fldfRYivx4RLO03z2SEfBHNOkmT2sTNn8GHgnH218vx/YwxVdk1VFKRHteSzeJB
         Opsw==
X-Gm-Message-State: APjAAAXQtncTVo1MEsjAGKIAgPn8mqHFGfD/DTyD0F8bAhxKl16FgPDG
	eQdKNypHNP0lT/j/MN/cH84QInzif6/bPp+WG/uVpxO2DcxGHzU65XYrNa9LNof5XaGpwzcVDfb
	b9x8WIkJ06OEsbzx7VcoJX5lAOG0Bv8ZZHqtr4Q9ZOfLJ64CECg/d9IseXkjjgjzxpw==
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr48820402pgr.72.1555004228689;
        Thu, 11 Apr 2019 10:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUZrSnDdHg34/lKapx0pn49NXYPFJ5fU47HhwOgMhs+cq16uXWPM+qw/lOR2BJhkfbNyX4
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr48820348pgr.72.1555004228008;
        Thu, 11 Apr 2019 10:37:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555004228; cv=none;
        d=google.com; s=arc-20160816;
        b=lOjeoo/Voly9Eso3/WM3kn6iATc7xMvrd9Xu6X4bdlx55ZS86jbT1Pmh3zQ9XcyBfF
         sQUuIOTQIT9j683Hhvub0HfMsPemrMn9kEYf3MP5e/DjvHaz18p0A2JG9LmGSYvw5jAC
         pk9txypgn6XaLrxAwvOoRrYGRlHTQrXZvm/j6cj5Q1LWM2Ic82hy0w+GE4dzPGMR/PRW
         r+cSBdiH7EhzdeN+3mqtzruZE0cz/EVpaH21DSxCUnvCzqrNJLRvmfPMDTDXWpaOtWdM
         /h3QVEM8Aw8/IECuXZQwEMv8VcRb3I6BLiGGRZP++NHTNraqt5QlBlKugQd6kq5cnepQ
         UjlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8lPWfr/fv9Mq3ZVmlINx7ayfGTvu31L2DN7bGB7z/yA=;
        b=F3GNQMiAuBtYUSHRvKvQdq2y3PPNAewLSlWjt+vrvg99Jx2BC5CZYC7KhYvpe4L3UC
         aWgjxk6YMpbVelXqyv3T10AEKK4ymljCxwW1zs1PU9FQaEhiK38L3EnBYF6oCIcaLqpG
         X5rokznREAE27S8j+dIm83LYA51pQh/J7YTfasQR3usZo2dBwoLV5BwrStDotOmTrR+p
         dvockf99ZWR0OIMh2b272p3Ssd7xNGO7jXWC6fNy3vZK2Qm7QiCL8ZijRuzTkWkZPjcv
         ON6D/rpaIRVi8rJrSWt9dTsAVKwalMAOyXutrHUf2M7ST1yC6lbpHp1lXikwhSMF0DT5
         oJRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TvJqi5e5;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p4si31727069pgh.526.2019.04.11.10.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 10:37:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=TvJqi5e5;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8lPWfr/fv9Mq3ZVmlINx7ayfGTvu31L2DN7bGB7z/yA=; b=TvJqi5e5iA8HNVMzgRG5pVg2C
	pnS4LZ+5q3WjTH+QWjGi5aCm1XHzH3c2/6EM5FWUbMBI/lpWFGzGZF22jxw8Dbt1KJamgRYaArC12
	nwRAZEY3GWcrMo16GsCRNHNC4UvhKXRZWe6XJF8p+/vgVvrGkci6l6+m2tLGy7zKPBcmny2+Xrrbo
	xZkYjM2cPhS0tQIJkJ40KVMfLY8DAwlBqXWMutjNQIK4kV4rfjhbpPjc0Nmg5WUXSVVMu9wv+9rsw
	/tIaOAMQMqdvrxhy9BMBNK+I8gxj+z9271ydZIrFihNqlAsI0TQ4xmJunIABdEg2xRoVcNLeultQL
	/LpvlJrfQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hEdd3-0004oy-Ps; Thu, 11 Apr 2019 17:36:49 +0000
Date: Thu, 11 Apr 2019 10:36:49 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Daniel Colascione <dancol@google.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christian Brauner <christian@brauner.io>,
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>,
	lsf-pc@lists.linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190411173649.GF22763@bombadil.infradead.org>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
 <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
 <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:33:32AM -0700, Daniel Colascione wrote:
> On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
> > On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > > victim process. The usage of this flag is currently limited to SIGKILL
> > > > signal and only to privileged users.
> > >
> > > What is the downside of doing expedited memory reclaim?  ie why not do it
> > > every time a process is going to die?
> >
> > I think with an implementation that does not use/abuse oom-reaper
> > thread this could be done for any kill. As I mentioned oom-reaper is a
> > limited resource which has access to memory reserves and should not be
> > abused in the way I do in this reference implementation.
> > While there might be downsides that I don't know of, I'm not sure it's
> > required to hurry every kill's memory reclaim. I think there are cases
> > when resource deallocation is critical, for example when we kill to
> > relieve resource shortage and there are kills when reclaim speed is
> > not essential. It would be great if we can identify urgent cases
> > without userspace hints, so I'm open to suggestions that do not
> > involve additional flags.
> 
> I was imagining a PI-ish approach where we'd reap in case an RT
> process was waiting on the death of some other process. I'd still
> prefer the API I proposed in the other message because it gets the
> kernel out of the business of deciding what the right signal is. I'm a
> huge believer in "mechanism, not policy".

It's not a question of the kernel deciding what the right signal is.
The kernel knows whether a signal is fatal to a particular process or not.
The question is whether the killing process should do the work of reaping
the dying process's resources sometimes, always or never.  Currently,
that is never (the process reaps its own resources); Suren is suggesting
sometimes, and I'm asking "Why not always?"

