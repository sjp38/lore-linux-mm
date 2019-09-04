Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0190C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B320E2341D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:15:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="XOb99Kzi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B320E2341D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49D8A6B0003; Wed,  4 Sep 2019 01:15:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 426AC6B0006; Wed,  4 Sep 2019 01:15:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EDBE6B0007; Wed,  4 Sep 2019 01:15:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 085E96B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:15:52 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 925A1513
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:15:52 +0000 (UTC)
X-FDA: 75896076144.21.crush55_16224de25365b
X-HE-Tag: crush55_16224de25365b
X-Filterd-Recvd-Size: 4542
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:15:51 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id b13so5826397pfo.8
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 22:15:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=t927y1khlcFbJ5TIcMQsCQQZ5PjZ/jC3FUiyzaKm0xU=;
        b=XOb99KzijvQur9tAY1DhfKGGRZI7vtlx/Beim1yaYj/lpuRs6X1wfG9SDUGcST4Kdr
         a+fBPIJYJ50KoXBDStczwTkBSXlbivAmRKwnRoKtVCcJrC3FqAWx5jqMwqWmZpsyr6h4
         khkJHK5GuH2aBTRCasn8yqND/okuCogJiSqkY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=t927y1khlcFbJ5TIcMQsCQQZ5PjZ/jC3FUiyzaKm0xU=;
        b=n5ESuAP3FnLHDMTmTjrLlN4rU3e82ejg2Kao6xr3qM76ze+sUE2X4d2RnPgOW6A8kf
         +fmftS369CgzMPfi/lojbkJDzohki0ixZdFa530j0yx4UD75/7YCpFWYjVtLlfp0LviA
         VtiCLqUxTIA1Ay9MMiPtN1oMVrDWHHFCOizNogH3ZyFyzQp5T1s8bB2HjfjyEcod+s/y
         8pqjbgPcBkkp3SA/DmoRFAy4WI2enB8R8XevyusLLLoG3BFhg7VTZVaY1Ge7FQdm7sG2
         ojzymOySLVuK5IT8flqq4rAc2ydqIHOF20GhyrDktKGZBw0pFgPCfEMv2f0g+gtIvMel
         GT1A==
X-Gm-Message-State: APjAAAXv774eVNaV0u/HPtmvmA1qHCnQB5bSSMwrSqCsT99Dc/o4ZGvv
	2GMHsO9usQPjOnTD9se6kDsIxQ==
X-Google-Smtp-Source: APXvYqzugh5tH8AehCVMWStbl6p9lwVs92YQnW+2nHFZFgFsUosZZJUnfaS9trtUmXFIX8piXL4olw==
X-Received: by 2002:aa7:870c:: with SMTP id b12mr5565098pfo.122.1567574151089;
        Tue, 03 Sep 2019 22:15:51 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id x11sm1566783pja.3.2019.09.03.22.15.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 22:15:50 -0700 (PDT)
Date: Wed, 4 Sep 2019 01:15:49 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Daniel Colascione <dancol@google.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>,
	Carmen Jackson <carmenjackson@google.com>,
	Mayank Gupta <mayankgupta@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	kernel-team <kernel-team@android.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>,
	Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190904051549.GB256568@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
 <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 09:51:20PM -0700, Daniel Colascione wrote:
> On Tue, Sep 3, 2019 at 9:45 PM Suren Baghdasaryan <surenb@google.com> wrote:
> >
> > On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> > <joel@joelfernandes.org> wrote:
> > >
> > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > memory hogs. Several Android teams have been using this patch in various
> > > kernel trees for half a year now. Many reported to me it is really
> > > useful so I'm posting it upstream.
> 
> It's also worth being able to turn off the per-task memory counter
> caching, otherwise you'll have two levels of batching before the
> counter gets updated, IIUC.

I prefer to keep split RSS accounting turned on if it is available. I think
discussing split RSS accounting is a bit out of scope of this patch as well.
Any improvements on that front can be a follow-up.

Curious, has split RSS accounting shown you any issue with this patch?

thanks,

 - Joel


