Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F7B8C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F41BA215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 20:42:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EaQyYCuf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F41BA215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E8556B0003; Wed, 19 Jun 2019 16:42:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 898168E0002; Wed, 19 Jun 2019 16:42:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AD2D8E0001; Wed, 19 Jun 2019 16:42:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59BBE6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:42:45 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id s67so700358qkc.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 13:42:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=TBgu1F4abnQgrkAM7sC23aDSMvrhGnN7FBKN+b/i6is=;
        b=kbcUgWIbn0qqqyp69IfpEPxXTV2ey01j6lcHRY+w5y8gjSEjaxO78monL5xPWUkyS5
         YZ6fSfy1yorqDhqfDK7gUzqfxsBaeaJlKWjoFSu7O69+ygtyGLQkWwPvIsNreAG1E7gV
         qpFEMs5YwWJLx8Vf0T4yFx0N/YNwPifvIf1fscAeABu5IQyfrbD+sLZbMjZ8R3i/DZRd
         YfIyTHdXaKNFlN6WMd2OHYsiDpe0hAbuvKgBnQHWF499urRSJKjBcvthGiVn43Tm0Hel
         xwdqgA64XNZBzmrtgBDb2bcAgsy9qhvrgfpHwyBeR3Pyr6ayzG5BwiYlEfgxB2XrCcEk
         ekUQ==
X-Gm-Message-State: APjAAAVcj7hRLrl9wOfOMd6fMDUh+NnwHNIK9d44vBkLtVMOsK8VaESd
	PPKLr3Sh4Mkjr922Su6D6T1cmmjhUjsqkTZS4DBfmiRq1MaNNaqBE5VL3WN9hmLY0nGhX0aaFP/
	c6HxbHWlbAviOC6ywUWmEoCSAQTnAAr93WTR2XROdn7oROUjS7Uwki9B2DnkbV2XkwA==
X-Received: by 2002:a05:620a:13b9:: with SMTP id m25mr39842377qki.246.1560976965081;
        Wed, 19 Jun 2019 13:42:45 -0700 (PDT)
X-Received: by 2002:a05:620a:13b9:: with SMTP id m25mr39842331qki.246.1560976964445;
        Wed, 19 Jun 2019 13:42:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560976964; cv=none;
        d=google.com; s=arc-20160816;
        b=tbHwK20XsGlJESwDX5sXTMoMOL3ygWr6gFA+5rXC6fI6Y+RgfJgjGp+yj3ZbDkEDL9
         7pPHqsPo3aasqOIra60n5l1QrWkaS04tsAYfcNkhGCe+iAyCmJb94jXzoax1IND+06TJ
         eWQ/B7JLg2UHmoTRZExIMR+22NlLNOJJgE35jaALcWwCxe/tRlhuuHsAm6laHFfXIqsX
         yG/grISTsyzoI+teq1W4ENIUL9DiCKxXGKdSGWChCOsbH0ymFNBmMMC7M6S6jtFFuZjq
         Jwi1N36bNl96/QpWlvECrabFm09pY7xiATw2RNCXSOxbM95HhCIT7ZJjRviszoa4+kJz
         HoMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=TBgu1F4abnQgrkAM7sC23aDSMvrhGnN7FBKN+b/i6is=;
        b=xuJQ7ozJOm2xxH3qAiwEKMv7ZKMF7m+H45/6QIFNQzq6epAe11pxjFU+qlXT8QirCj
         HrFPYL11dQqbYMezMq+Y/28pEi5HOlgAWK9pQRQmBa77916MbcDODpTB23Bmwh2KjmwS
         mn94wBcgA2aqUM8EVgs97ZocnVmi7fX7x29NfxyDsKjzOx8mXHhAV5jz7+6QMbIv0ya/
         9Gw9a9a5duszhFeADjeR1i7nmyD9zAXVafzXaDnUbfOpYFiZhrdAVzIbxBD09oeu3Drf
         wVv0wIhwjbl0VT/04xTkkrbY7wXSBbvbF4RL7iQeyXRFIUKCc53FQZB7DPlZPRbxXbR5
         JKgw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EaQyYCuf;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t188sor12354755qke.1.2019.06.19.13.42.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 13:42:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EaQyYCuf;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TBgu1F4abnQgrkAM7sC23aDSMvrhGnN7FBKN+b/i6is=;
        b=EaQyYCufZoEOHUrhA5C65HJeWWPQ44TPFwOFRGPSs/kadihvsNLaI7C/q5Lx8nN+Ag
         sSDJ00GlbBb7AJQltrBt4pAJwniFtTcJwmPfocq+9b/luxO0IGfSUSCUcqNBfJDLTEJK
         tB9u05+y9B2z2wjTFsd1vtJjyBLIpYpd/eq94rM0W2qq4HuwikeZhRhGE2DCMw8Kh+XN
         k5mEjEVJVKN3SSaBa9vFnUXWcZjDEkf4Rj6INQpXctWJQ+wQ2KMy1BsL2lqcmQdWLVPw
         rX7ZLwMaAvHaIuHIm75mR3SW8q1aJpTlLjILf0Y2XNeQqa7qWoAclPlvugKKMyVxXGnU
         tGhQ==
X-Google-Smtp-Source: APXvYqwkpP3oHvZN3nRaQ3RbrtVXeyrf0MwnUp9n/IQIWK8LXxln8+qpmD6ZJN85f7XPHS4TGxx0zg==
X-Received: by 2002:a37:a854:: with SMTP id r81mr25171872qke.53.1560976964070;
        Wed, 19 Jun 2019 13:42:44 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id q36sm14171694qtc.12.2019.06.19.13.42.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 13:42:43 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdhPn-00033G-4Y; Wed, 19 Jun 2019 17:42:43 -0300
Date: Wed, 19 Jun 2019 17:42:43 -0300
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
Message-ID: <20190619204243.GM9360@ziepe.ca>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190521154411.GD3836@redhat.com>
 <20190618152215.GG12905@phenom.ffwll.local>
 <20190619165055.GI9360@ziepe.ca>
 <CAKMK7uGpupxF8MdyX3_HmOfc+OkGxVM_b9WbF+S-2fHe0F5SQA@mail.gmail.com>
 <20190619201340.GL9360@ziepe.ca>
 <CAKMK7uGtXT1qLdUqnmTd9uUkdMrcreg4UmAxscx0Fp4Pv6uj_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGtXT1qLdUqnmTd9uUkdMrcreg4UmAxscx0Fp4Pv6uj_A@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 10:18:43PM +0200, Daniel Vetter wrote:
> On Wed, Jun 19, 2019 at 10:13 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > On Wed, Jun 19, 2019 at 09:57:15PM +0200, Daniel Vetter wrote:
> > > On Wed, Jun 19, 2019 at 6:50 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > On Tue, Jun 18, 2019 at 05:22:15PM +0200, Daniel Vetter wrote:
> > > > > On Tue, May 21, 2019 at 11:44:11AM -0400, Jerome Glisse wrote:
> > > > > > On Mon, May 20, 2019 at 11:39:42PM +0200, Daniel Vetter wrote:
> > > > > > > Just a bit of paranoia, since if we start pushing this deep into
> > > > > > > callchains it's hard to spot all places where an mmu notifier
> > > > > > > implementation might fail when it's not allowed to.
> > > > > > >
> > > > > > > Inspired by some confusion we had discussing i915 mmu notifiers and
> > > > > > > whether we could use the newly-introduced return value to handle some
> > > > > > > corner cases. Until we realized that these are only for when a task
> > > > > > > has been killed by the oom reaper.
> > > > > > >
> > > > > > > An alternative approach would be to split the callback into two
> > > > > > > versions, one with the int return value, and the other with void
> > > > > > > return value like in older kernels. But that's a lot more churn for
> > > > > > > fairly little gain I think.
> > > > > > >
> > > > > > > Summary from the m-l discussion on why we want something at warning
> > > > > > > level: This allows automated tooling in CI to catch bugs without
> > > > > > > humans having to look at everything. If we just upgrade the existing
> > > > > > > pr_info to a pr_warn, then we'll have false positives. And as-is, no
> > > > > > > one will ever spot the problem since it's lost in the massive amounts
> > > > > > > of overall dmesg noise.
> > > > > > >
> > > > > > > v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
> > > > > > > the problematic case (Michal Hocko).
> > > >
> > > > I disagree with this v2 note, the WARN_ON/WARN will trigger checkers
> > > > like syzkaller to report a bug, while a random pr_warn probably will
> > > > not.
> > > >
> > > > I do agree the backtrace is not useful here, but we don't have a
> > > > warn-no-backtrace version..
> > > >
> > > > IMHO, kernel/driver bugs should always be reported by WARN &
> > > > friends. We never expect to see the print, so why do we care how big
> > > > it is?
> > > >
> > > > Also note that WARN integrates an unlikely() into it so the codegen is
> > > > automatically a bit more optimal that the if & pr_warn combination.
> > >
> > > Where do you make a difference between a WARN without backtrace and a
> > > pr_warn? They're both dumped at the same log-level ...
> >
> > WARN panics the kernel when you set
> >
> > /proc/sys/kernel/panic_on_warn
> >
> > So auto testing tools can set that and get a clean detection that the
> > kernel has failed the test in some way.
> >
> > Otherwise you are left with frail/ugly grepping of dmesg.
> 
> Hm right.
> 
> Anyway, I'm happy to repaint the bikeshed in any color that's desired,
> if that helps with landing it. WARN_WITHOUT_BACKTRACE might take a bit
> longer (need to find a bit of time, plus it'll definitely attract more
> comments).

I was actually just writing something very similar when looking at the
hmm things..

Also, is the test backwards?

mmu_notifier_range_blockable() == true means the callback must return
zero

mmu_notififer_range_blockable() == false means the callback can return
0 or -EAGAIN.

Suggest this:

                                pr_info("%pS callback failed with %d in %sblockable context.\n",
                                        mn->ops->invalidate_range_start, _ret,
                                        !mmu_notifier_range_blockable(range) ? "non-" : "");
+                               WARN_ON(mmu_notifier_range_blockable(range) ||
+                                       _ret != -EAGAIN);
                                ret = _ret;
                        }
                }

To express the API invariant.

Jason

