Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D8DBC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 22:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9DCD218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 22:59:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=dallalba.com.ar header.i=@dallalba.com.ar header.b="QUb9euxW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9DCD218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=dallalba.com.ar
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6FDC6B0003; Mon,  9 Sep 2019 18:59:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF8156B0006; Mon,  9 Sep 2019 18:59:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBF6E6B0007; Mon,  9 Sep 2019 18:59:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id A5B2D6B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:59:35 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5279C181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 22:59:35 +0000 (UTC)
X-FDA: 75916900710.10.drop05_8ddae1fb99836
X-HE-Tag: drop05_8ddae1fb99836
X-Filterd-Recvd-Size: 4107
Received: from mail-qt1-f170.google.com (mail-qt1-f170.google.com [209.85.160.170])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 22:59:34 +0000 (UTC)
Received: by mail-qt1-f170.google.com with SMTP id j1so5635890qth.1
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 15:59:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dallalba.com.ar; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=6c3KElRK7s3lIRwdrBhOpeBhrMPrJmWMITNxxfo1c7c=;
        b=QUb9euxWn70QZSHrNeR2UtklU1bWA0IMQTjjZr2f2FIvvBffTJbmPJmU+5YpgaKJ4w
         ZhVsgcUV25wL59FMdSKwFFZrp/1q6j/fNHJKIj3ZNln0CZBNKQvPmLoaqMl7zUax0Rtc
         xQBf3AqLeIZXYFQJd7+PagKgPjrbyX1/gjIEc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=6c3KElRK7s3lIRwdrBhOpeBhrMPrJmWMITNxxfo1c7c=;
        b=rucRrt6//I4gRVN79aslLDx+aaaf7xPqJ0zUmLMeH0F+7LYUoDImYnTNCxF3nKDDrS
         Ju98YywqUaEq5LCx5Jk7NTzuK0ln2fObiyDhyHBqkdGIkOmw7v1KvJ8qGe7ikkT4keZe
         jxuzCCN10xNRQJhaHSwvZDlMkWSc59YSH0Ws1HLZvwzP2CeajQ0IPMTz41Fce0LpkHvP
         TKjEleaOsyQsLPyWD2MXp6RG+wlwv6v29//EZ7g6ExQ8uUv9JIhEkHi6U6k4cm8OkOZ7
         vKgJMXXh4UduHk+/kgiSBSt9kKgx1j8IflgBu7Lh5wvuYD54EKkBq5gjEwLaFT4ixThY
         40Tw==
X-Gm-Message-State: APjAAAWnmlZi8nzA/NuF23J4vSmWu2t0TVMoo8dDowMRA5VCm6eTSLtT
	l8lE7g4SC5u4g3dBI232gDsi
X-Google-Smtp-Source: APXvYqzD97Of4vZmJXG8r7bTyI8iMgaeD13knBwlFf4X3P2S2F2PS2hLK9HnFs8qM+tKWkLpuIR02w==
X-Received: by 2002:ac8:140f:: with SMTP id k15mr11543512qtj.34.1568069973986;
        Mon, 09 Sep 2019 15:59:33 -0700 (PDT)
Received: from atomica ([186.60.230.244])
        by smtp.gmail.com with ESMTPSA id m7sm7002633qki.120.2019.09.09.15.59.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 15:59:33 -0700 (PDT)
Message-ID: <28453b3deba00d9343fdcbde5bcda00e7615d321.camel@dallalba.com.ar>
Subject: Re: CRASH: General protection fault in z3fold
From: =?UTF-8?Q?Agust=C3=ADn_Dall=CA=BCAlba?= <agustin@dallalba.com.ar>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Seth Jennings <sjenning@redhat.com>, 
 Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, Henry
 Burns <henrywolfeburns@gmail.com>
Date: Mon, 09 Sep 2019 19:59:30 -0300
In-Reply-To: <CAMJBoFNa3w5zHwM8QOUgr-UUctKnXn3b6SzeZ5MB5CXDdS3wwg@mail.gmail.com>
References: <4a56ed8a08a3226500739f0e6961bf8cdcc6d875.camel@dallalba.com.ar>
	 <3c906446-d2fd-706b-312f-c08dfaf8f67a@suse.cz>
	 <CAMJBoFNvs2QNAAE=pjdV_RR2mz5Dw2PgP5mXfrwdQX8PmjKxPg@mail.gmail.com>
	 <501f9d274cbe1bcf1056bfd06389bd9d4e00de2a.camel@dallalba.com.ar>
	 <CAMJBoFNiu6OMrKvMU1mF-sAX1QmGk9fq4UMsZT7bqM+QOd6cAA@mail.gmail.com>
	 <CAMJBoFNa3w5zHwM8QOUgr-UUctKnXn3b6SzeZ5MB5CXDdS3wwg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.4 
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 14:44 +0200, Vitaly Wool wrote:
> On Mon, Sep 9, 2019 at 9:17 AM Vitaly Wool <vitalywool@gmail.com> wrote=
:
> > On Mon, Sep 9, 2019 at 2:14 AM Agust=C3=ADn Dall=CA=BCAlba <agustin@d=
allalba.com.ar> wrote:
> > > However trace 2 (__zswap_pool_release blocked for more than xxxx
> > > seconds) still happens.
> >=20
> > That one is pretty new and seems to have been caused by
> > d776aaa9895eb6eb770908e899cb7f5bd5025b3c ("mm/z3fold.c: fix race
> > between migration and destruction").
> > I'm looking into this now and CC'ing Henry just in case.
>=20
> Agustin, could you please try reverting that commit? I don't think
> it's working as it should.
>=20
> > ~Vitaly

I reverted the commit and I haven't seen the deadlock happen again.
Should I be experiencing some side effect of having reverted that?

Thanks,
Agust=C3=ADn


