Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53FC0C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:13:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15261208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:13:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="cLoTJVoj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15261208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5E5E6B0003; Wed, 19 Jun 2019 16:13:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0EEE8E0003; Wed, 19 Jun 2019 16:13:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D5508E0001; Wed, 19 Jun 2019 16:13:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4056B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:13:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x10so534712qti.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:13:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pgcngtEs9uVcYhtJPpPurWF53FUixqD8oD/gTijpCZs=;
        b=BIZefsj9J3Qg0Ixh/jn9qfF+WUP/F9Im94s5u3KbLd7WVG37OokXHfo3iTJXj/ekvW
         PTvPP/bmwIiQ72D9bB+rkSnXEzSbuDzOOtryiCx/bZUcdc8whV1wfXRNUpii1uCHEkn8
         2ESToqaeLsak8oFgeW2LxV7br6537E3N286xO7imLF6C9pPkGScmSoXzHzVZuVzDcOyM
         d/KEbf8DeYp10+pv+FgM5XXKAqyxebcUCM6COqAFYgfJJ14ID2623sQ52A+cUWHt4X81
         9k9H89/qlsvtMOYEtliTETKm1MCJuQzeg6EJ5AJjy9flasovymWHncenTre1z6sJR/4K
         LtZA==
X-Gm-Message-State: APjAAAX6utBW7o6G1XPw4mveX0kmCHRP3moyFWf6br6pljD5orlqUAz/
	FNF52aTCS7+f7iyXzDWTt5dEZaLlSxI4TMXhcFIGa6mKPeRuXnqQmJKtgaA61iL7nanyOCar/qp
	uXL9xhQwc10LAJFrj4hu3w8wzTNCrPYv6pFiiRSL561rIspK/QmCp1EPZdw89V6Mz4g==
X-Received: by 2002:ac8:87d:: with SMTP id x58mr109106026qth.368.1560975222132;
        Wed, 19 Jun 2019 13:13:42 -0700 (PDT)
X-Received: by 2002:ac8:87d:: with SMTP id x58mr109105965qth.368.1560975221488;
        Wed, 19 Jun 2019 13:13:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560975221; cv=none;
        d=google.com; s=arc-20160816;
        b=OEgvN7epcqPdAfKQa+XpmhRbnHKYnqhtQS98UzCQjs35Jb5dbO3CtNwgWy1Ss6ROfI
         StrCRAYjCY3GEYpMo5hp04ddF5jGzoGiVJPFzFIk92VtXp7X/4Wy8X3rwAF4YcqBVeIg
         FJas0WUX+gwsrJUimHiUL9fZBQ613Z6z6keDLaLh60/zc3Oq5FuUBWe7jIQWsiFd/Cp4
         rQmL9qb/2cjbdYCFH1gPISL/v6St/XIXfio7t99J+WfoDEARlZdpIzpxq5HrSqjNpgow
         uZOZYWen8gEWdHgtFxxgIxDBTHf5U6rXxNfnmIasCxeWk+kWXO8w6S9uQWnaH/AdQuBD
         RAWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pgcngtEs9uVcYhtJPpPurWF53FUixqD8oD/gTijpCZs=;
        b=bubQl+xV8ikZ7sbNGE9KuQfTm7Tqdsx7BJcBtUar0q1L0luQgB0sOwW7e6qNrqzGVP
         e+2GTgWe/bTNntUZ6KHr6z6uXK0vOJlAlW2ItMafZHcmk3NPbk8NBOKqgEcBACVC0ir6
         BT0VS7zdrUT1maB2u/vEJrGmy5sGnIMG8aDszcYiKBphAU/6/bGrqjCKzbV3pRRS/yNI
         y8OeC3MU8ea9FXCII46PSpmfcgeUhvGqgNpKwp08f3Dv59KgFiNRIFaJ6UGJcgcT8kew
         rO2mm3ProsyzufYiLG2Nm6kaU9d4sEU8rOh0gyKWTkKMB2X3KawaQ/n2XMv1jDJZAI46
         AM8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cLoTJVoj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v63sor12433945qki.43.2019.06.19.13.13.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 13:13:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=cLoTJVoj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pgcngtEs9uVcYhtJPpPurWF53FUixqD8oD/gTijpCZs=;
        b=cLoTJVojiiY28gDdbS4BiMud3Q2ttCA35wRWS9+enmEKV/fFhoK5HMbRgWCMRNjzCQ
         b5ZrG1xcUBu7h6XelJpG4UMUjYJIzXdXfvpPiSyGYKdOweQ8twH8VntPLrq71j/TsSLy
         jpJZxemlj6uSAxjIlpkxEfVLL6t4SnPV1Na+7aRJWlC/JUKSKlZ2Kb2Z4WwTJsvlN637
         Cevv50iZDvZBGXCN6Gv70gfCH3gmRKeT9j0XQcvmKxIGDNpJ19N3X2W+pEIfCgtmESSX
         foHoQot+LMBKmcpM4/NBKgRFPmN0qLPKRN6ubqbiqKhMYESz50hc7k0uZOGPL7CFxZJG
         aZsA==
X-Google-Smtp-Source: APXvYqx89CcDrXNyjbTWXMmP5tm+atmaNtgywjB10MJ+6xvDJdWKl3S7Qx9ZNBRu4t92EqyHMT9VzA==
X-Received: by 2002:a37:4cd2:: with SMTP id z201mr54688926qka.284.1560975221161;
        Wed, 19 Jun 2019 13:13:41 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 34sm12796326qtq.59.2019.06.19.13.13.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 13:13:40 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdgxg-0002nE-42; Wed, 19 Jun 2019 17:13:40 -0300
Date: Wed, 19 Jun 2019 17:13:40 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>
Subject: Re: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to
 fail
Message-ID: <20190619201340.GL9360@ziepe.ca>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com>
 <20190618152215.GG12905@phenom.ffwll.local>
 <20190619165055.GI9360@ziepe.ca>
 <CAKMK7uGpupxF8MdyX3_HmOfc+OkGxVM_b9WbF+S-2fHe0F5SQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGpupxF8MdyX3_HmOfc+OkGxVM_b9WbF+S-2fHe0F5SQA@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 09:57:15PM +0200, Daniel Vetter wrote:
> On Wed, Jun 19, 2019 at 6:50 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Tue, Jun 18, 2019 at 05:22:15PM +0200, Daniel Vetter wrote:
> > > On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> > > > On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > > callchains it's hard to spot all places where an mmu notifier
> > > > > implementation might fail when it's not allowed to.
> > > > >
> > > > > Inspired by some confusion we had discussing i915 mmu notifiers and
> > > > > whether we could use the newly-introduced return value to handle some
> > > > > corner cases. Until we realized that these are only for when a task
> > > > > has been killed by the oom reaper.
> > > > >
> > > > > An alternative approach would be to split the callback into two
> > > > > versions, one with the int return value, and the other with void
> > > > > return value like in older kernels. But that's a lot more churn for
> > > > > fairly little gain I think.
> > > > >
> > > > > Summary from the m-l discussion on why we want something at warning
> > > > > level: This allows automated tooling in CI to catch bugs without
> > > > > humans having to look at everything. If we just upgrade the existing
> > > > > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > > > > one will ever spot the problem since it's lost in the massive amounts
> > > > > of overall dmesg noise.
> > > > >
> > > > > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > > > > the problematic case (Michal Hocko).
> >
> > I disagree with this v2 note, the WARN_ON/WARN will trigger checkers
> > like syzkaller to report a bug, while a random pr_warn probably will
> > not.
> >
> > I do agree the backtrace is not useful here, but we don't have a
> > warn-no-backtrace version..
> >
> > IMHO, kernel/driver bugs should always be reported by WARN &
> > friends. We never expect to see the print, so why do we care how big
> > it is?
> >
> > Also note that WARN integrates an unlikely() into it so the codegen is
> > automatically a bit more optimal that the if & pr_warn combination.
> 
> Where do you make a difference between a WARN without backtrace and a
> pr_warn? They're both dumped at the same log-level ...

WARN panics the kernel when you set 

/proc/sys/kernel/panic_on_warn

So auto testing tools can set that and get a clean detection that the
kernel has failed the test in some way.

Otherwise you are left with frail/ugly grepping of dmesg.

Jason

