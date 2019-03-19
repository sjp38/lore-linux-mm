Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2857C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:26:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A06762077B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 16:26:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bMpTj/1K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A06762077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 342ED6B0003; Tue, 19 Mar 2019 12:26:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8D46B0005; Tue, 19 Mar 2019 12:26:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 192166B0007; Tue, 19 Mar 2019 12:26:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBD596B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 12:26:11 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d24so20268832qtj.19
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:26:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0hjtMa13v+1TUnJOQudts9/ZTMsjYEIbzhdVS2GJjaU=;
        b=kMnvCNbfu+X8nK4x5yxVrNNhlopNq//Tym++d5HllGx02cfO6Lcw6I5P9ui9cEpNaE
         AwpD9XK9l8hHb71/6lFRFx/EKHGv3MgZq9bOygc3uSVKIQi1Ap0Dmdmp5Fmw7S9+Wiqw
         m8p4NXTZEJjpksyXifZMVGYUCoqz5W5DxZ0gvH+mZReQtul9FQ0h/pzMy+6ySjNSPMt0
         vjKF7vvR9MDi8M2E2aIWSpDZAHwY0mKwDAp4cSo/qESIZHRPh1JB6RGUyCFVTBAAoBwq
         NiBl4eJhqdueErx6zkvxFrJbimk5rmk56wZKPS7lkztyrxspV0OspgM+j3OpCNyTntts
         5gQA==
X-Gm-Message-State: APjAAAXC0KGcQcp3ga7WDhe/lUDjTmxMuGTgKloiRqL4aJwy889nyxGa
	/RaUqnLXh9/cWbx8Ir099nCyY8bu+0ecqty5IanzirvLtVJWbwT7q1qN5kEeDoDO1qnyuOji1oQ
	OiO/XqdmWkw3L9mhzQvykRDXxcWzC0xmQy5TYfw2Mb59I6EC37tVkuOJEUVTKry3IJw==
X-Received: by 2002:a37:cfc3:: with SMTP id v64mr2638113qkl.144.1553012771514;
        Tue, 19 Mar 2019 09:26:11 -0700 (PDT)
X-Received: by 2002:a37:cfc3:: with SMTP id v64mr2638078qkl.144.1553012770798;
        Tue, 19 Mar 2019 09:26:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553012770; cv=none;
        d=google.com; s=arc-20160816;
        b=ukFDE6fBBNEMQei+4va8eC3LzDlI32wJLBt6pgdLEwMqnXmNf4IsZ8jcknvRx6Q+sP
         mGGk1xXAWHXQ3a63hpAWxhMx93BL2h7mzUpd5Ltu9Lw79Nfw1GX5uDnHVzMTRNS3qQ9s
         4cHao0jjkqjKqZn52mSeQLr592a9vY54m7BnRcP2DuHfrD5cWgq4LFqtt7xYyIVKRyiI
         cPpHtnLesdMGU0mUQ0XxGkvUPBO5GHYfaSSLWPsXfSL+ridXsdVactAWq4dMORClEE6J
         ccsWGFjyvnPyVPKCCd4xoenMs4LQ2Svx2ys6KP1Sav5Qon/wo1fSdFEGohbmVBToWKi7
         rwpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0hjtMa13v+1TUnJOQudts9/ZTMsjYEIbzhdVS2GJjaU=;
        b=p1OgqWfoQbSBB5B242Ry0FgNVmGiaBRg1tHF7TT3K5m7d2lO+Wc0WOy4tIif0CwwfX
         AdFVim3WLSKEK9pShwkJhPY+w87Xy+LENdsfdSOP0THFQfaVnVq5P2WNDxBUgmut7Gmq
         B2YkcSIQTvgQkYaCl5TtAelA0qwDh3QZGRidVGh1YEAcZiAnsi+YpLiPKJEDa9l2L0U7
         XhqdxEmGhipri+jl1frWzqXGcxZ599PPpwBSbOAimGrdP+6Qj5IAaACu3RKhY4IEFSvC
         fiOmlQSD3OSzhcqZlpykCJG+a3EHoTFlGBwLol5NjnmKFuxY+vqnpw0/fhMoIcWs167v
         xI9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="bMpTj/1K";
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f49sor16649114qtf.14.2019.03.19.09.26.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 09:26:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="bMpTj/1K";
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0hjtMa13v+1TUnJOQudts9/ZTMsjYEIbzhdVS2GJjaU=;
        b=bMpTj/1K6yfIMzZt0cVJ00EWR1Yx8DNdtfvjqsvFNWFcWG6iV0lTZ1sHDJntk0WLE4
         tnj8fuZF0Q6TSzX5BiN/ON5d7D6Q3T6UTo46EiOcf4IOAvBX+XpfNJGlTOFnLoWEPAWc
         p77BfextnD7ZVnCOx0O52bG1ZFFhoB+Ve8lKv+ezxt2c7ryHipbdsU2HL/7fVL0gi5ao
         rIIEdH7ww/tgi90kYblBVEEbilkRFU46MySMfOfDaE5/QrSTRF2aqqjeaWBkxEzS4F4J
         PHfaOSFvemyRAFES1anXMAps+um3VsosYkNDYg/+Dh/b7oMjgig50aYqv4gp/iQglrih
         ienQ==
X-Google-Smtp-Source: APXvYqyx094SutD1/obXksKxalllPThYfUGmOtc9gU+noHbsU0zTJ4/CyrwHoZeZUp0b4MmEC/eK42o0F/sBokkcS8w=
X-Received: by 2002:ac8:3629:: with SMTP id m38mr2821402qtb.369.1553012770361;
 Tue, 19 Mar 2019 09:26:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190315160142.GA8921@rei> <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de> <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
 <20190319144130.lidqtrkfl75n2haj@d104.suse.de> <20190319145233.rcfa6bvx6xyv64l3@kshutemo-mobl1>
In-Reply-To: <20190319145233.rcfa6bvx6xyv64l3@kshutemo-mobl1>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 19 Mar 2019 09:25:58 -0700
Message-ID: <CAHbLzkpo4KHBN8YCCGGfrDnoX4FnEx6odgEUwweGTC5fGz4FQw@mail.gmail.com>
Subject: Re: mbind() fails to fail with EIO
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Oscar Salvador <osalvador@suse.de>, Cyril Hrubis <chrubis@suse.cz>, Linux MM <linux-mm@kvack.org>, 
	linux-api@vger.kernel.org, ltp@lists.linux.it, 
	Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 7:52 AM Kirill A. Shutemov <kirill@shutemov.name> wrote:
>
> On Tue, Mar 19, 2019 at 03:41:33PM +0100, Oscar Salvador wrote:
> > On Tue, Mar 19, 2019 at 05:26:39PM +0300, Kirill A. Shutemov wrote:
> > > That's all sounds reasonable.
> > >
> > > We only need to make sure the bug fixed by 77bf45e78050 will not be
> > > re-introduced.
> >
> > I gave it a spin with the below patch.
> > Your testcase works (so the bug is not re-introduced), and we get -EIO
> > when running the ltp test [1].
> > So unless I am missing something, it should be enough.

Thanks for adding the missing part.

>
> Don't we need to bypass !vma_migratable(vma) check in
> queue_pages_test_walk() for MPOL_MF_STRICT? I mean user still might want
> to check if all pages are on the right not even the vma is not migratable.

I think we need. As long as there is "existing page was already on a
node that does not follow the policy" with MPOL_MF_STRICT, it should
return -EIO. So, even though the vma is not migratable it should check
if the above condition is true or not.

I will wrap all the stuff into a formal patch.

Thanks,
Yang

>
> --
>  Kirill A. Shutemov

