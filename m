Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DF9BC04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:04:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CC4020835
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:04:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="V17+lfAq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CC4020835
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE84A6B0006; Tue, 30 Apr 2019 12:04:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D99B96B0008; Tue, 30 Apr 2019 12:04:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAFD16B000A; Tue, 30 Apr 2019 12:04:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD1346B0006
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 12:04:09 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id q127so12277145qkd.2
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:04:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=7C/H9ZzSU0qP8UYq2NJoxOTSjxthMtozx8jthqagPTo=;
        b=curVcUGT0OYegVig2XTxErYnjaZLBKrIL4sHJ50+zZoahx2usO3r7f0hvLU40AGNVR
         o/Wkf6Skc+NsySq7SykU3/+msdeOAH24P2AZfiAOvw3GRyBA8W/GVM7HitzndeUnrHIo
         LWC4tKY2hT2SbrYBD9eriSjfuwGmoGx2o+zkJ0ev7Na4XUb8vOyZhgR1gxWRrG1ZlSL5
         vYiygEm6h4CKL/DHJ+sQKKlRc4iv8SAteABSlTkaZ3eMqorQdYgNxTOMa0O705EcR5mb
         SzmwEt4aQOnyP0Y1kG7SS0acf6iQ1WjQvLMj5ASGHpXTUsYMKZCQ4yn7POBIkB9KrDjp
         Xi1g==
X-Gm-Message-State: APjAAAV0PiE631jb2Qe2lzPQnnNUeFzrOi/69llEudYhbsuvSGgaNGmu
	iZUjv5u8mJ/AgN4ZFNvj4Fd3Nr83UabFyc4wAvhFn7tXS1sCcl/Ixi+gKIAPtUzFxOy8I97gQvD
	w0LFWEBic62ciVhWXf0UyeCxS3YR8WTsrh/ZINstsBle/5LUZVqPg8jYxmbnQWrOLzg==
X-Received: by 2002:aed:3143:: with SMTP id 61mr14954641qtg.80.1556640249372;
        Tue, 30 Apr 2019 09:04:09 -0700 (PDT)
X-Received: by 2002:aed:3143:: with SMTP id 61mr14954564qtg.80.1556640248512;
        Tue, 30 Apr 2019 09:04:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556640248; cv=none;
        d=google.com; s=arc-20160816;
        b=XAAvo8mLz5HxjIlYq2udYdlwLejeu0ugB7JburNlV9UL4flhWJvGtLOQJiSYnPgXtD
         3OcP62tC55Voollc7eWipOlGdIrUxvNTSwrNjZSivNFEfTi0bRe/r1pxeC6OAR7+b6CZ
         o5Gt0i6hXJaXIPHy97/XeM9iZHq15EIrxv8l9TE1eG2nZrJ2qlMtDLYh7hVBc02qvj0P
         RHrj3F5lLM3UQOtMmGJpRD7uKqP/JhULTAzxOg21QNcx27CMVifACgMxGhfjrRD3jKBU
         jsW91q3+muWIIAkHglLPNthN1FmDiP0xmi1vlqpNaHMSWCQ2YbvSJJ2A22B6gUV55Nr8
         Dctg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7C/H9ZzSU0qP8UYq2NJoxOTSjxthMtozx8jthqagPTo=;
        b=qyPIwyDqG5DtepKXVf/HMUQScfrL4j4OR1lJdZxK6M6M8yhiiZ+M9CgE7DtZGu2KAH
         qmLD8Lix4tW+HPBnsgLnuaBBpRY57bRbBilCfuusPzuZy8raUwCQyPOfoP1UXnTKNP11
         xqSPmtuCCYC9E474BH+ORSTxfbJ1tdBtme/j/acqrndBQnNhvi4s2lkhlMGwuIu3tl/K
         EkffvLmbKWYLbejxuZBdfTevM1ENKlbUoFYsbRYT2f4COvNx2s1fewBVU3YeRUh0GKEQ
         a7zU5B9IDX65i/Nygi8DuUahmELlUFko3oyLGA6G8MlCXizWODm+GXRW6n8VNUP5cnCc
         1A7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=V17+lfAq;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r20sor16913151qvh.40.2019.04.30.09.04.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 09:04:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jwadams@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=V17+lfAq;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=7C/H9ZzSU0qP8UYq2NJoxOTSjxthMtozx8jthqagPTo=;
        b=V17+lfAqUPk01IFJXUO56hClBUX2HDbxSbQULpTYSKkdi7HyAd33jfH5SIR8cXdcvE
         hw/F9aMeFlPeuK5f4rBww/6N/Xmuv3823rpt63eVEiC0Qan/UjihZuDkm9RygVdZFQS+
         uDXcBV7siz7kiet+/qLVaIcLptgJ9iivk9KSHlfQPKEm/K6sK09PpdfaQ642KUtpoLIG
         Ei/9gzhfAHqdmqH0fjfZyrt7AVGrIzU5C9CHggarLYx36WwDp5F8075K02Wntqlwb84c
         HpvByXvkJ7w/RAav80V4R5dscpV10nEf8hg1TH2pyWT4QZjAgYqwSCLSFK5QFiXIrs9J
         nWbw==
X-Google-Smtp-Source: APXvYqwcvQfk6RKX1YA+CEknGA6KPVffr8HcdjX65JCcNo0SBSztv0+v1lrmNaDd0LojAXwHvRQTc8ngINVBxL3bMxI=
X-Received: by 2002:a0c:ae17:: with SMTP id y23mr31197725qvc.199.1556640247675;
 Tue, 30 Apr 2019 09:04:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190425200012.GA6391@redhat.com> <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
 <503ba1f9-ad78-561a-9614-1dcb139439a6@suse.cz> <yq1v9yx2inc.fsf@oracle.com>
 <1556537518.3119.6.camel@HansenPartnership.com> <yq1zho911sg.fsf@oracle.com>
In-Reply-To: <yq1zho911sg.fsf@oracle.com>
From: Jonathan Adams <jwadams@google.com>
Date: Tue, 30 Apr 2019 12:03:31 -0400
Message-ID: <CA+VK+GP2R=6+GQJHX9+d6jnMWgK8i1_H5FiHdeUe3CGZZ5-86g@mail.gmail.com>
Subject: Re: [Lsf] [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller ?
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Jens Axboe <axboe@kernel.dk>, lsf@lists.linux-foundation.org, 
	linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, 
	Jerome Glisse <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org, 
	lsf-pc@lists.linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 7:36 AM Martin K. Petersen
<martin.petersen@oracle.com> wrote:
>
>
> James,
>
> > Next year, simply expand the blurb to "sponsors, partners and
> > attendees" to make it more clear ... or better yet separate them so
> > people can opt out of partner spam and still be on the attendee list.
>
> We already made a note that we need an "opt-in to be on the attendee
> list" as part of the registration process next year. That's how other
> conferences go about it...

But there was an explicit checkbox to being on the attendance list in
the registration form, on the second page:

By submitting this registration you consent to The Linux=E2=80=99s
Foundation=E2=80=99s communication with you with respect to the event or
services to which this registration pertains.
* The Linux Foundation Communications ...
* Sponsor Communications    ...
* Attendee Directory
     By checking here, you opt-in to being listed in the event=E2=80=99s
online attendee directory. Some of your registration data will be made
available to other event attendees in the directory (name, title,
company name only)

Why isn't that sufficient?

Cheers,
- jonathan

