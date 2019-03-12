Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8799C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81A5B214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 21:52:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81A5B214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A7968E0004; Tue, 12 Mar 2019 17:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02FBF8E0002; Tue, 12 Mar 2019 17:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E61018E0004; Tue, 12 Mar 2019 17:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A67198E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 17:52:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f6so4117724pgo.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:52:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CuBuYaWBKyWBM5yH3DOmb3KPNrTs2wT1Q2Sc72T9CDg=;
        b=obk1OojgD84VY7WJvl9N0GT95uUWgJ5M63XDKVdSQLmKce8H6DSmyh3+9VwzQH5s4C
         tlIIwLSMNf4UYN3vVK9dn0DvevMWI+o+FAwkNfG9PkSkYPKzaGjj9aFwuWIk6UWAITZh
         rraExAFi20bGUID74PEXic1Flwjwz7gb6Fx9Yy+IeaJofEhS7orXAF8zX0eGWDsSQsw6
         OeXQoq5ZkJv78ptWHMnOpyxyr6VR4eXIkWwI1JRIh8/Lvl/jXifNfnMzXRWCLgOnqCOQ
         eEVgJcmRbg1QQ38DFQPz0Lsc/VTydTHeDokrbUR39gyrspV1XyvBA4ObKRs1WDPv8gMp
         qS/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAW1Kr31tBYQoQJ6PMrt3Gz7HFypZuVP4KDLYRyWbqSS4xPBTncm
	Cp/pZ/XM/B+KTfcoZ5x3sneytBrF8YKUUbcvvlATC/xlykfY7CbayThvPT6HzIpDL/9Ed2AjbWo
	yZlSu4ilURMi6muFzUONCe5A6jeHJoPcrP0jZlfPOZ4GGbFo2ulC28qvazVrq5nn0Qw==
X-Received: by 2002:a63:29c4:: with SMTP id p187mr15598535pgp.230.1552427537274;
        Tue, 12 Mar 2019 14:52:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzP9sotoGkHZm/ehygpXk/tD+5+gxIMKgpM9AUilo9dYW+STzd0QRr/IqHeXthJkobyqvLw
X-Received: by 2002:a63:29c4:: with SMTP id p187mr15598479pgp.230.1552427536133;
        Tue, 12 Mar 2019 14:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552427536; cv=none;
        d=google.com; s=arc-20160816;
        b=hMOyHQqFjGAC4SjrPNiAAPhnBMxBLYa6q2/YI9+xuo8rZDynZXSfkoyaXL3SezZaVX
         lgmTaMZfhbZAwd30c1D/7YrtsRI45IqjVDQZvnuSH5ft08nM2ygPsG76VHspwS4nWUKD
         9gMC1Qfejc2JexaLeQYJ7nvo/qHSaFzw0tjvY6L1tAKxT/xA9S3sv+uPQwZ2LBw2q2sQ
         49etTwY7kkUDtxibj3dOUTPfOnBk3tbOBpUpXH7iAU+XWpjl6InH9X+v/IPS23klMFk1
         pI+fuVhy3QWwSmNOW9sE3nIZ5HyJOls+8Tz6ZYgHMe9KpVru9bVDe9RSFH8cCpbir5tn
         QK/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=CuBuYaWBKyWBM5yH3DOmb3KPNrTs2wT1Q2Sc72T9CDg=;
        b=bz6xmlh5a609ltVC1J0RJ8DcADXLy7HM4MPrwM37sZ8CQCVlrJpqTrDtQoF78p+gJR
         ngbhpWNreM66MfA3I+6hfB272NWvAy+TUHGoCrfyvvZ0L6PtPPMBGJw8U8HQSlUgMbZt
         FiKuxM661tXAISDRmIyDJYt/YCCWBiK+BgLUyXX3v5Bn+w0Ntj83HhsAvnovCmvAsiGQ
         9tGE5Nu/Sf5JTOVW09Fz2HgXYBU3CpNPWudkVn3/uIi3vYwRQHefeuM1JveYER0pAD2Q
         0wGlE3QpQkxYlPRBez4mE17774TJALnyOoYSmRjvmtiakkHvTPV/fjwvl7qkGEK0D1dj
         bfBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s194si8513841pgs.47.2019.03.12.14.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 14:52:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 60C34CBA;
	Tue, 12 Mar 2019 21:52:15 +0000 (UTC)
Date: Tue, 12 Mar 2019 14:52:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-Id: <20190312145214.9c8f0381cf2ff2fc2904e2d8@linux-foundation.org>
In-Reply-To: <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
References: <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
	<20190131041641.GK5061@redhat.com>
	<CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
	<20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
	<CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
	<20190307094654.35391e0066396b204d133927@linux-foundation.org>
	<20190307185623.GD3835@redhat.com>
	<CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
	<20190312152551.GA3233@redhat.com>
	<CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
	<20190312190606.GA15675@redhat.com>
	<CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 12:30:52 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> On Tue, Mar 12, 2019 at 12:06 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > On Tue, Mar 12, 2019 at 09:06:12AM -0700, Dan Williams wrote:
> > > On Tue, Mar 12, 2019 at 8:26 AM Jerome Glisse <jglisse@redhat.com> wrote:
> [..]
> > > > Spirit of the rule is better than blind application of rule.
> > >
> > > Again, I fail to see why HMM is suddenly unable to make forward
> > > progress when the infrastructure that came before it was merged with
> > > consumers in the same development cycle.
> > >
> > > A gate to upstream merge is about the only lever a reviewer has to
> > > push for change, and these requests to uncouple the consumer only
> > > serve to weaken that review tool in my mind.
> >
> > Well let just agree to disagree and leave it at that and stop
> > wasting each other time
> 
> I'm fine to continue this discussion if you are. Please be specific
> about where we disagree and what aspect of the proposed rules about
> merge staging are either acceptable, painful-but-doable, or
> show-stoppers. Do you agree that HMM is doing something novel with
> merge staging, am I off base there?

You're correct.  We chose to go this way because the HMM code is so
large and all-over-the-place that developing it in a standalone tree
seemed impractical - better to feed it into mainline piecewise.

This decision very much assumed that HMM users would definitely be
merged, and that it would happen soon.  I was skeptical for a long time
and was eventually persuaded by quite a few conversations with various
architecture and driver maintainers indicating that these HMM users
would be forthcoming.

In retrospect, the arrival of HMM clients took quite a lot longer than
was anticipated and I'm not sure that all of the anticipated usage
sites will actually be using it.  I wish I'd kept records of
who-said-what, but I didn't and the info is now all rather dissipated.

So the plan didn't really work out as hoped.  Lesson learned, I would
now very much prefer that new HMM feature work's changelogs include
links to the driver patchsets which will be using those features and
acks and review input from the developers of those driver patchsets.

