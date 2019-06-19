Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00C5EC31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0749206E0
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:50:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KMoNMAk8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0749206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F0CF8E0002; Wed, 19 Jun 2019 12:50:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37A8D8E0001; Wed, 19 Jun 2019 12:50:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21A7C8E0002; Wed, 19 Jun 2019 12:50:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id F328F8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:50:57 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u129so16252917qkd.12
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:50:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=qZ7DILVFzp78tcp4G5VOohWGeQIPrvQGvihKnIg9H7E=;
        b=dTen71m3Kll9NO9cb3ZAfRVAJLLJVyocc2Dp4OSs5ydciOWCQU01ukzQaNbDmDuFhW
         +R43orYvTRimh7uQHRMbmviv752gRFRMKXwciN0ducyzr2jLiYaG1vS9VoU746AxOl0k
         qn23tgqxuxWRA7xz6W4jiQDUN5gzv5iodARI2npaMswEw/Vf43Qfcw4MLx8DD+mkSDei
         +vbJyh+DrYvXW/iwUqU0Avbe7aSn9caHkOYVGEWp8NFsh9y8eQp0RZ77HxPtN/p5qCHi
         tW/OopXSFsOwUqdOoqLTwdAKwwSLjwQd6l6mibFFlflJDhnHzFCeBgw0KgTZvquc9bWL
         Jngw==
X-Gm-Message-State: APjAAAWPyEvsc0kUMlGGzF3Q7l2/TEbCCkC5ahVm05aQl3Ulb+tszNgo
	W5ONsOs8JjaN4iAwTDlKDMGPy9Olr7YdpsRvye53e+pnRcdAHjuNb/nRbbuNrymE9clvHnN4FDH
	EsQLY/eGNyle/W6ze2BVzmWqJM83nxSgEhtgcnrpEPBidoUEsmw6PyF2LUGh7UtQvtQ==
X-Received: by 2002:a37:a244:: with SMTP id l65mr83528766qke.118.1560963057736;
        Wed, 19 Jun 2019 09:50:57 -0700 (PDT)
X-Received: by 2002:a37:a244:: with SMTP id l65mr83528701qke.118.1560963056932;
        Wed, 19 Jun 2019 09:50:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560963056; cv=none;
        d=google.com; s=arc-20160816;
        b=BeSH58VmLXh6PXBYU9UvBFqqUkrnSFAeS2JUyco6bsBoBY8XtMTstwJtlmieDO0yoD
         cvmD3oEwfcssGiYYXwVaA/tenyvSWgmxWYzgIPhFKeL3kaRkFz2Gzr3wzR4t/J+bAruq
         A+5kpuDQzISMzRNPjgmc6JQdzYWjQ8uZ0hedg3tIJeunN5TXBci0QfMMY0QBn+SSGJ6z
         wRzX2CA6TgFsOBWQ1Oon+COZVq7lY7ThNx4HpbbOD4eOkpF9Bg00EhmInJgtHKXePfht
         X8cTL98DzWN0Oq9jAuhQm2MuYDpDqAm9bvz0d8zhfVIt6UHlnaq2LqD37tzuSUofzUQW
         IOLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=qZ7DILVFzp78tcp4G5VOohWGeQIPrvQGvihKnIg9H7E=;
        b=ulJCEmgObJkaSXx/3wF1FTgXFcurnYqheVawrbp7xf5flgQkhiLRer18pmyOFvpWQY
         2V9vjFIU3cx6bSl7IUWcwHsOvI5VizQ1x4aFNmtA3/a34RSV7V6UMwEhYKjTRWterPGa
         Q/UvqDhKZXcrsvc403mReUktV63T4JDu9Y52pOxefwkY4W2aJ0egGUvkJgnWcfu8g5U+
         FykxtfFFWRBPjUWOgvTD9/8CtWG+G6liCg1x2I9g+HPX8+9wEYCWxj4J5d+N52027ksP
         D9i+eqMMHmLgaagNmNnSTfycy/Ukt66hvjlvSAOBal0odyXnmd8uTUAIhriUdRXAEMtT
         IZiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KMoNMAk8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l30sor16210053qve.59.2019.06.19.09.50.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 09:50:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KMoNMAk8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qZ7DILVFzp78tcp4G5VOohWGeQIPrvQGvihKnIg9H7E=;
        b=KMoNMAk8Ui9/LtKeNa7HIyVKWhexKtOyUwM0YsZQI+1McUXlVPzPHPca+hUWtgwo/6
         03T2AvAUYyMxuNukN8dIy79whNPI9nkupfg9cH6LdySpEzUgauwhQFADzdyRe4Hvu1pY
         fDPLXTlCjygXw/QMhggf2P4CsbK4+s0v1QuBXUz4vFWJeGTQZFX/hUl7EC5MO9D/u2Xs
         NbXmeZUZ9Rt9lNVx3eXE/mU35xwWdDiw3jHn52j89OeRFlTDfy6CEZ1RraQEIP19d7mm
         VyWkyW+DGheaUcNRMXcsg92KDqLEdhfiLfFXP/kmU/pLCATJWbXUUz0VDhB0JqXgdvW1
         UIiQ==
X-Google-Smtp-Source: APXvYqwORT7n/pvkyNBXMNfOBu1GA78NLHvBz3GZoS2rYJCKw8+BpnU4WCUnG74vXzc78GqCKrZy8g==
X-Received: by 2002:a0c:e6a2:: with SMTP id j2mr32663508qvn.190.1560963056606;
        Wed, 19 Jun 2019 09:50:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m44sm14096849qtm.54.2019.06.19.09.50.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 09:50:56 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hddnT-00022a-N7; Wed, 19 Jun 2019 13:50:55 -0300
Date: Wed, 19 Jun 2019 13:50:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>,
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
Message-ID: <20190619165055.GI9360@ziepe.ca>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com>
 <20190618152215.GG12905@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618152215.GG12905@phenom.ffwll.local>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 05:22:15PM +0200, Daniel Vetter wrote:
> On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> > On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > > Just a bit of paranoia, since if we start pushing this deep into
> > > callchains it's hard to spot all places where an mmu notifier
> > > implementation might fail when it's not allowed to.
> > > 
> > > Inspired by some confusion we had discussing i915 mmu notifiers and
> > > whether we could use the newly-introduced return value to handle some
> > > corner cases. Until we realized that these are only for when a task
> > > has been killed by the oom reaper.
> > > 
> > > An alternative approach would be to split the callback into two
> > > versions, one with the int return value, and the other with void
> > > return value like in older kernels. But that's a lot more churn for
> > > fairly little gain I think.
> > > 
> > > Summary from the m-l discussion on why we want something at warning
> > > level: This allows automated tooling in CI to catch bugs without
> > > humans having to look at everything. If we just upgrade the existing
> > > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > > one will ever spot the problem since it's lost in the massive amounts
> > > of overall dmesg noise.
> > > 
> > > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > > the problematic case (Michal Hocko).

I disagree with this v2 note, the WARN_ON/WARN will trigger checkers
like syzkaller to report a bug, while a random pr_warn probably will
not.

I do agree the backtrace is not useful here, but we don't have a
warn-no-backtrace version..

IMHO, kernel/driver bugs should always be reported by WARN &
friends. We never expect to see the print, so why do we care how big
it is?

Also note that WARN integrates an unlikely() into it so the codegen is
automatically a bit more optimal that the if & pr_warn combination.

Jason

