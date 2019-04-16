Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3FD5C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:38:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A45C20868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:38:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A45C20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0715A6B0003; Tue, 16 Apr 2019 17:38:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01E8F6B0006; Tue, 16 Apr 2019 17:38:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7A246B0007; Tue, 16 Apr 2019 17:38:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B14B26B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:38:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f67so14901757pfh.9
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:38:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2AS+NXCc7sVgwiTnENU1eambjyHcV/PXcGNjHzgoFSM=;
        b=ZBhzIz0MhbjV9+YJhqr1HzwZI/7VOYPQJjgyWpp2qJcT6Zd5wnjYGpfGe4z0qYN9Nq
         1HL+H8CF8b+/6zzrBPSzR6k6OhVruGcmNYy8dhAdS5iRQ+9xCMoQs7GWQNd8T9QKyoAS
         OVtcwyZlN3jhJxdrx+fVYGFFcWpRlhu1MwLEW0eYQYwnO5lZt6SY6hOt2oGlipHneAAl
         eTZQLyOfXTdQQd1rif4ZmynZ7j9Vr09/6AqhyMBLWDQtNZyq0nYpn8uG9Jg9dQWCqwc4
         mlwXM1EcckCWj9u/FOUUVrVCB2UQulB0vwtuqAVJrhDiO0f7yDdLYLk+r4WAGeRDIYke
         X++Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUhwhMswgbwSIFfX1dxuSEazoPudRuM0zOgi73t+Uf6dsA7wC1b
	OoJ+QDSYAMSvmFVbeOwSxpJZioetGLMkMGxD6FfcM9zSthk9Y5WJXrORVnwGY7HDdUySwPG/veO
	5JAymsOMWWpWoKSqacGAdsOVX8gCsrwyGqisI+y16rbFpFknlQpFS4XHjTFXmkkmVsQ==
X-Received: by 2002:a65:6144:: with SMTP id o4mr78736937pgv.247.1555450696385;
        Tue, 16 Apr 2019 14:38:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq15dzcdS7KK5+eUr1m1NEVJLf8DK4ca3QE4YXLycgoCxHGB37xskrjbyifBK7/6eXBXWC
X-Received: by 2002:a65:6144:: with SMTP id o4mr78736882pgv.247.1555450695590;
        Tue, 16 Apr 2019 14:38:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555450695; cv=none;
        d=google.com; s=arc-20160816;
        b=jRcjyRmFvv/y2E1Th/NMXplU596GleUsDMydk8eoizy4tH3SU8sV/OSUuyVWYnbA1C
         /AYl6JfUU4eZFXWHG8GTAnGzEKnNBBiw3XRWzLpdmo6hD1vzp8MDFbDtjLzVLylySdNI
         R6h43ecl75qUF3TT7gpNc5jZpAETSnKcWItIy4exWezvzLxEjPrIioHD7DBnUJ/7Zc3c
         Ax0WPd1NtgELiTFcdQ59DY4cUVb1l2OcZaNL1ot6x/2qmsqb9cfTevjnt7qtLYgJyB8A
         M0wub1ntRmrY9HhEVbeyV9MQq7wegCDfPzA3atq5/wgmHJ9qD+hg/bNICvLrbBl27qPK
         Qe7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=2AS+NXCc7sVgwiTnENU1eambjyHcV/PXcGNjHzgoFSM=;
        b=MFzKVdDvQfhN33TTKd/84S7N9ijCcRY9khDofKV2ONpy8PSx5a1z4BbRGJsxHx9IlV
         BoynkakTttz8RFvOcOYHH7AqRFKgOp02sdkCNl5HjNcBqWJ4LHZ1Ao1GGSs0GVhSx9Ce
         oGJsAUxneLeF6+SPKKGR8iGWjhjs8qPYtGUnzFrhgla/d3xetcEBTyC5Gn9KcOPI0Hbi
         RZlD6GvOQV16cTG5dJpQecHWq/4J3NoSWhEWLzUjMA6qFuC1zK0iivcYiTxnI8uiBPZs
         WKv/6XnlPKga/AiduRfnCO63MiSzgkAj3uNaaQfJcig/RoULnXXu2f83sSL1qPI4ktFh
         cuzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j7si50010791pfb.75.2019.04.16.14.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 14:38:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id A2030E21;
	Tue, 16 Apr 2019 21:38:14 +0000 (UTC)
Date: Tue, 16 Apr 2019 14:38:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Tri Vo <trong@android.com>
Cc: Nick Desaulniers <ndesaulniers@google.com>, Greg Hackmann
 <ghackmann@android.com>, linux-mm@kvack.org, kbuild-all@01.org, Randy
 Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>, LKML
 <linux-kernel@vger.kernel.org>, Petri Gynther <pgynther@google.com>,
 willy@infradead.org, Peter Oberparleiter <oberpar@linux.ibm.com>, Jessica
 Yu <jeyu@kernel.org>
Subject: Re: [PATCH v2] module: add stubs for within_module functions
Message-Id: <20190416143813.4bac4f106930f6686164c11b@linux-foundation.org>
In-Reply-To: <CANA+-vAvLUFPhfXj_CxkV8Fgv+zmqvu=MxwtwFTbr5Nrn68E9g@mail.gmail.com>
References: <20190415142229.GA14330@linux-8ccs>
	<20190415181833.101222-1-trong@android.com>
	<20190416152144.GA1419@linux-8ccs>
	<CANA+-vDxLy7A7aEDsHS4y7ujwN5atzkGrVwSvDs-U3Oa_5oLFg@mail.gmail.com>
	<CANA+-vAvLUFPhfXj_CxkV8Fgv+zmqvu=MxwtwFTbr5Nrn68E9g@mail.gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Apr 2019 11:56:21 -0700 Tri Vo <trong@android.com> wrote:

> On Tue, Apr 16, 2019 at 10:55 AM Tri Vo <trong@android.com> wrote:
> >
> > On Tue, Apr 16, 2019 at 8:21 AM Jessica Yu <jeyu@kernel.org> wrote:
> > >
> > > +++ Tri Vo [15/04/19 11:18 -0700]:
> > > >Provide stubs for within_module_core(), within_module_init(), and
> > > >within_module() to prevent build errors when !CONFIG_MODULES.
> > > >
> > > >v2:
> > > >- Generalized commit message, as per Jessica.
> > > >- Stubs for within_module_core() and within_module_init(), as per Nick.
> > > >
> > > >Suggested-by: Matthew Wilcox <willy@infradead.org>
> > > >Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > > >Reported-by: kbuild test robot <lkp@intel.com>
> > > >Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> > > >Signed-off-by: Tri Vo <trong@android.com>
> > >
> > > Applied, thanks!
> >
> > Thank you!
> 
> Andrew,
> this patch fixes 8c3d220cb6b5 ("gcov: clang support"). Could you
> re-apply the gcov patch? Sorry, if it's a dumb question. I'm not
> familiar with how cross-tree patches are handled in Linux.

hm, I wonder what Jessica applied this patch to?

Please resend a new version of "gcov: clang support".

