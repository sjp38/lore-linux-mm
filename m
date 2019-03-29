Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 557CBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1146A20700
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:01:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1146A20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A25986B0007; Thu, 28 Mar 2019 21:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D6226B0008; Thu, 28 Mar 2019 21:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4906B000A; Thu, 28 Mar 2019 21:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 67E086B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:01:08 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h51so679315qte.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:01:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rwp7V5lLPdaj+nAjoBmdNcN/aCF8GcZtyuXce7hl5ps=;
        b=GBhzeNdRQwYqj0IWCARR1/HWNnX4c3nPJbCZDebK+fCjJvWlzfOPbn334euzgxdHDM
         Kp5dM641ydMQGwhdyZ3QdKZJKeNb//Js5gjG488l9GYbC3yHLActQyrzJCHTEaXQtlnv
         eOA7qjgmer1v2/vRC0wo70JzYS6oegaX6MA3K91EtzWdso/Y6SXPDU17nVxYp8PpN31l
         7s0SWBoOp97s/J54ZzWaV/fsDncmZlGVSQJRCc0BiJ2WZegToM27kAlt0Kl3XgIzdF9F
         e0yVFxp7JF9M/gv7mncj5tlTDixTNkTwRiCK5ey40BtLIyLGQrPLojMH6Cc0tFMnCDrY
         r31Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUrIf4612yOkKiF6MXZTkYFcY14D1Ca9q3r556vTEU6fI5bfl5Y
	dC/8WvTEcEeOkz3Ou0Sp/oYwU5P9YYhNdjjpKo7VQouURvSqIsR3lqZcP2qZUuRdGtGnAJ5iqht
	nmCIHnnNsBnAKsEXRLwYrim9PTUvvNnPmjj82q8ofOfLRUUoXP0arEyblhNZ6h3I/QA==
X-Received: by 2002:ac8:925:: with SMTP id t34mr22877876qth.30.1553821268130;
        Thu, 28 Mar 2019 18:01:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzN2WpLAAbphkvU+HvYRyY9K8lX0n2vwVj5dhTt0eUuUhaWmcgNg8KSlrENO24IMI7T+PSu
X-Received: by 2002:ac8:925:: with SMTP id t34mr22877605qth.30.1553821264225;
        Thu, 28 Mar 2019 18:01:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553821263; cv=none;
        d=google.com; s=arc-20160816;
        b=JEVToeJ1qxVgFFYQusurR4LFIowFdAHAYhnH/kGJTg1Sl3eLXcguQMUYozY1orVIin
         ee0yJCDBfGFPH0FfGiltCI5z+vbaAM6BfE93FRKqVbjaYNUVXCGLDATBVJsbHPv3w88u
         BRrcbMFBc1eeiJQ0Fw+w4rI+waSWA+kqsGMb48+6q4gQfEm3kHiUyYfE1KVDn5OEyCIV
         jxlmvImS8PhTOEVe0VBcxoA/kgrOMErElk1b7pDj++5HrXIerXJ1Ig1X8Y0aVGDMHDEh
         0vljsicrRzXzAhT6s9edEcpPuD3C3lHewn1S0qLn1TaYxRLofBYldqdXTQNaJDJ4lK5Z
         fObA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rwp7V5lLPdaj+nAjoBmdNcN/aCF8GcZtyuXce7hl5ps=;
        b=JAMAPxHda1p5eigMvIK2zzPizf65JnyaqJruj1hJ0jbsWGW1aN0rLRsdGcDgCgVVFz
         +dR3WE8x1HHFTYBJlhLCRkP4kDcK7ux72/NE8dHJ731Osfww7Dfco/jHUWa/a+DELUET
         /91bB/awS03H7Wj79aYoyOOqK3PP9gB8aL16vJ3aK6a9bKSw7xOmgF0l53UQKV+3vTnT
         gCLkECnTWUInAjOYlHakm+E6UHmfwv+trbfry6yUTs1qXHK5h1Uz2K8MPZJ4Gj+nBbcQ
         SoONKTO01TY5dRH2sr1OeEOzoeyV9jVnZ8PZHQ9nm/c81T8dWu0xoE3LKn6cWC2YhpcU
         mbDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q46si130532qtf.237.2019.03.28.18.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 18:01:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D239088ABB;
	Fri, 29 Mar 2019 01:01:02 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BE88362669;
	Fri, 29 Mar 2019 01:01:01 +0000 (UTC)
Date: Thu, 28 Mar 2019 21:00:59 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
Message-ID: <20190329010059.GB16680@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
 <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
 <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 29 Mar 2019 01:01:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 09:57:09AM -0700, Ira Weiny wrote:
> On Thu, Mar 28, 2019 at 05:39:26PM -0700, John Hubbard wrote:
> > On 3/28/19 2:21 PM, Jerome Glisse wrote:
> > > On Thu, Mar 28, 2019 at 01:43:13PM -0700, John Hubbard wrote:
> > >> On 3/28/19 12:11 PM, Jerome Glisse wrote:
> > >>> On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
> > >>>> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
> > >>>>> From: Jérôme Glisse <jglisse@redhat.com>
> > [...]
> > >>>>> @@ -67,14 +78,9 @@ struct hmm {
> > >>>>>   */
> > >>>>>  static struct hmm *hmm_register(struct mm_struct *mm)
> > >>>>>  {
> > >>>>> -	struct hmm *hmm = READ_ONCE(mm->hmm);
> > >>>>> +	struct hmm *hmm = mm_get_hmm(mm);
> > >>>>
> > >>>> FWIW: having hmm_register == "hmm get" is a bit confusing...
> > >>>
> > >>> The thing is that you want only one hmm struct per process and thus
> > >>> if there is already one and it is not being destroy then you want to
> > >>> reuse it.
> > >>>
> > >>> Also this is all internal to HMM code and so it should not confuse
> > >>> anyone.
> > >>>
> > >>
> > >> Well, it has repeatedly come up, and I'd claim that it is quite 
> > >> counter-intuitive. So if there is an easy way to make this internal 
> > >> HMM code clearer or better named, I would really love that to happen.
> > >>
> > >> And we shouldn't ever dismiss feedback based on "this is just internal
> > >> xxx subsystem code, no need for it to be as clear as other parts of the
> > >> kernel", right?
> > > 
> > > Yes but i have not seen any better alternative that present code. If
> > > there is please submit patch.
> > > 
> > 
> > Ira, do you have any patch you're working on, or a more detailed suggestion there?
> > If not, then I might (later, as it's not urgent) propose a small cleanup patch 
> > I had in mind for the hmm_register code. But I don't want to duplicate effort 
> > if you're already thinking about it.
> 
> No I don't have anything.
> 
> I was just really digging into these this time around and I was about to
> comment on the lack of "get's" for some "puts" when I realized that
> "hmm_register" _was_ the get...
> 
> :-(
> 

The get is mm_get_hmm() were you get a reference on HMM from a mm struct.
John in previous posting complained about me naming that function hmm_get()
and thus in this version i renamed it to mm_get_hmm() as we are getting
a reference on hmm from a mm struct.

The hmm_put() is just releasing the reference on the hmm struct.

Here i feel i am getting contradicting requirement from different people.
I don't think there is a way to please everyone here.

Cheers,
Jérôme

