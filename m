Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EFD9C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:42:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00506213F2
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:42:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="CDRaOIDr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00506213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4136B0005; Tue, 19 Mar 2019 14:42:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 871E66B0006; Tue, 19 Mar 2019 14:42:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 761CD6B0007; Tue, 19 Mar 2019 14:42:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC376B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:42:13 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id u18so932089otq.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:42:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FWxmWiMBWpI9PbQuON8dITDlnyzakUDvlB+9hBH1Ids=;
        b=m/7XA4msZ39M2K3I6NEIYK1FV6hHlggjZ7jv6/Vrys8a332g3zbAfBj1uRxKK32cj1
         z+Z44b+kNZTw9+c1cdlXJOz3XkBUUdat4R3BbX5ewq54hKkuNM1AtFDoQS1soO2asyyY
         pulY/WGbICyGUXbxSfUEoe8ajXUSqKHppEZfik7UBjsc2bvNPm51pOpZPANWscQCqky8
         dU5Zdcsb9YbuUioHFXdW2TESSF6z3ADT1+4cSL7xwaZkuTPT+W3RlsRUVH1Pqu9PVQTZ
         lZ1gLtBaEkHOGQYhVayFCNZDFMZbnHhq0UFVVY4QMo3qvjyx1ACYYih3ReidsPmxKSDm
         btQQ==
X-Gm-Message-State: APjAAAWCUe1myqcDB8MrvGOyZrUQvDIgCXygOGB1ewk7mW30G9NUwzc4
	qNyS946jKqNUzQgs/izXe4z+J4F4DDwvHAfDfFUExgJyG13LK7hQEhb8Ux3vPfTW4IbzlD70b8K
	yKVrEMmApzcTY9bq5+rlCcsMRH3HT1kBYDk3+g6n1y83+aUTNa7dlC9nfwf4r4u6RLg==
X-Received: by 2002:aca:bb83:: with SMTP id l125mr2430618oif.23.1553020932815;
        Tue, 19 Mar 2019 11:42:12 -0700 (PDT)
X-Received: by 2002:aca:bb83:: with SMTP id l125mr2430575oif.23.1553020931720;
        Tue, 19 Mar 2019 11:42:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553020931; cv=none;
        d=google.com; s=arc-20160816;
        b=fiO3medofmdNo0HXzk9O205znXP5hl3rshr8L/qlo3766pw45tnlKGzv7RhB3Ct77w
         IsdbBFKErVss5te9cDzEc84/mth0d2kA0sV4avxhRLjqUHuOEb6GrmcpRbjaA9911jJr
         aa5YqLWBTMwGFPZHS0hmgOE7IIGHtxToKTAuhBfvON5O9fmOoksf7JwIRGUSMJi+o1cS
         H+u4uS5lQbaXa5eQdTjitbjonxgozRGasqMkFjO0E3hWYlYkHWAr8gFDMzRZgSHfHc3P
         DisbOAXc1ulCHg2UNhCitb+KEzRPjJJ1llDORYYSTTZfUxK2No2P+iE59QxuSrOI5gc8
         TP6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FWxmWiMBWpI9PbQuON8dITDlnyzakUDvlB+9hBH1Ids=;
        b=IIjQ9HfjdtTPHY9tlDI3FivBHdElxyGLeLMH4ThuICRVtzgtlNcG4d/oePCpXT9BVW
         2RR6ftFwG+0FBelPIh65q5XM55Yu8ay7qsedCSwHsYlvNErjd3jirZel9r+KPX9gVDN7
         ZqyWcZ9k4HNh+IBFycYEufEVQGLSg8CSJsbTXp56mwN3AhxRG7nK1oHcFlPMIeUTzvlJ
         M4bcYTkBGhsg0GKquJfEjD62eCUFbI9+YxkRRVA45kcV6yJ9dKJR0Syz6S2O/1fyU8C1
         j+oZp7MZXCIFCei9jvw+aMdMC0SF+4DMrO2QMNQPWsu/AZS3byTqIrQNLTgWvU24e6dA
         Xerg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=CDRaOIDr;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor8816872otl.0.2019.03.19.11.42.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 11:42:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=CDRaOIDr;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FWxmWiMBWpI9PbQuON8dITDlnyzakUDvlB+9hBH1Ids=;
        b=CDRaOIDr7xEbWdkSWHxkSt92zwgalV46Gy1oD8i1LIvOi7IbJAf6KZa6N+ffH9Y8vP
         xttdPrp5cEdzGBKDYbSE0mqgkFZXnu6mnC4uTzRWIUsFOcVCQnSoX+/BJ+yB8sxj0crp
         WHtiyXiOP51RdMLhdhqQ65UDDyPeZHHLpSElmKfrWJL53Ukntprdm52hpjnoYnHpPGNF
         jrP5MMkZT4/+HDIXeuG3a0k+sa+gcalCFRuEA9qOCuvRKxtzkr/X4zIfEhDcM8Lo+QDR
         ySabqrj0PvLlNkldased5jAwHXmzaW+EXT+zkIaKWEIpD+S1kEHQmENLzU9DFKi7//b/
         xjhg==
X-Google-Smtp-Source: APXvYqyahvBwQYIcUDTqr0Q4YyUcML89NFCLSqd+Kz3QIKSS3JZTj1jVT4LvJzG7zKr8/In8vsgYSeZhBPIbrQOkTBI=
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr2080569otf.98.1553020930814;
 Tue, 19 Mar 2019 11:42:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com> <20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
 <20190319165802.GA3656@redhat.com> <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
 <20190319171847.GC3656@redhat.com> <CAPcyv4iesGET_PV-QcdBbxJGgmJ_HhoGczyvb=0+SnLkFDhRuQ@mail.gmail.com>
 <20190319174552.GA3769@redhat.com>
In-Reply-To: <20190319174552.GA3769@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Mar 2019 11:42:00 -0700
Message-ID: <CAPcyv4hFPOO0-=v3ZCNFA=LgE_QCvyFXGqF24Crveoj_NTbq0Q@mail.gmail.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Alex Deucher <alexander.deucher@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 10:45 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Tue, Mar 19, 2019 at 10:33:57AM -0700, Dan Williams wrote:
> > On Tue, Mar 19, 2019 at 10:19 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > On Tue, Mar 19, 2019 at 10:12:49AM -0700, Andrew Morton wrote:
> > > > On Tue, 19 Mar 2019 12:58:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > [..]
> > > > Also, the discussion regarding [07/10] is substantial and is ongoing so
> > > > please let's push along wth that.
> > >
> > > I can move it as last patch in the serie but it is needed for ODP RDMA
> > > convertion too. Otherwise i will just move that code into the ODP RDMA
> > > code and will have to move it again into HMM code once i am done with
> > > the nouveau changes and in the meantime i expect other driver will want
> > > to use this 2 helpers too.
> >
> > I still hold out hope that we can find a way to have productive
> > discussions about the implementation of this infrastructure.
> > Threatening to move the code elsewhere to bypass the feedback is not
> > productive.
>
> I am not threatening anything that code is in ODP _today_ with that
> patchset i was factering it out so that i could also use it in nouveau.
> nouveau is built in such way that right now i can not use it directly.
> But i wanted to factor out now in hope that i can get the nouveau
> changes in 5.2 and then convert nouveau in 5.3.
>
> So when i said that code will be in ODP it just means that instead of
> removing it from ODP i will keep it there and it will just delay more
> code sharing for everyone.

The point I'm trying to make is that the code sharing for everyone is
moving the implementation closer to canonical kernel code and use
existing infrastructure. For example, I look at 'struct hmm_range' and
see nothing hmm specific in it. I think we can make that generic and
not build up more apis and data structures in the "hmm" namespace.

