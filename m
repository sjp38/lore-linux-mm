Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC81C3A59E
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 21:28:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDFFE20870
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 21:28:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E7XWS51m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDFFE20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A0856B0006; Mon,  2 Sep 2019 17:28:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 551076B0008; Mon,  2 Sep 2019 17:28:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 466CC6B000A; Mon,  2 Sep 2019 17:28:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0172.hostedemail.com [216.40.44.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2500E6B0006
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 17:28:14 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8F87FA2CA
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 21:28:13 +0000 (UTC)
X-FDA: 75891268866.26.pump97_64e44f67a1f2b
X-HE-Tag: pump97_64e44f67a1f2b
X-Filterd-Recvd-Size: 4874
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 21:28:13 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id 4so13694511qki.6
        for <linux-mm@kvack.org>; Mon, 02 Sep 2019 14:28:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=m5Tr8peCYLPTBLyG4jlj+OLhYRR0ev+4cBo1n2zucSI=;
        b=E7XWS51m3HrCCTEixm5DCt3mCnbxRvgSDNLcJNwLa+R4y1JIjfRngyCAtllxj7BiDV
         QXSvevY8BokCCfeECi4pWRDaupFZQ6gaOBdFwoHvyuMn3hh0ueJtchjxb+/pZ8fibZYY
         AYtVk6gogONa8YRAddmi9iNLn6SXWOFGuBgPDbLmI0UuopSdZgtT1FPRv+5bJUSzP9Ju
         Lp/778ylNxlmOoTesZOF75ZgMBtAvAZfz+aBqMBpvhIIT6JS2KUHJOA3k9DtmPGZktjy
         CxFywRTqNgyBJQfWJmuN4Cf3XFB/HBs9BONoBLBlwdhhpJYf+0HjHk7gWvjCEJnoo1qM
         zx8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=m5Tr8peCYLPTBLyG4jlj+OLhYRR0ev+4cBo1n2zucSI=;
        b=Lco2hwk54A+w/P1M+gpWCeRpNcdQ3YGopvyg3n6O9st/OAFAtENrHSm9VXfP/+R+/p
         wz5miCTUeP4Yn5DaeLfqDh97BGHXSbz5PlrTlsKHfpwYhFt8b9VdCMIKfNsT7dZAUey6
         CXUAXUY6tSAC4inbEq33yanKH8jvN/wfYzCm0pk1J/wKRIprCeFjyBmyuEuy67CDMtKR
         pH5nUC/chPPPDYhzgX8/sUn+dC+2BWL9XPhmnaRTyoOaR85r7R/kPfZWGpjklcbcBrXM
         5j4ln52bA4P40plQ0RoaqKyzLEzroevsEczdfCwDq1KNXZaUs25Bi8QflJ90XBZlqiNP
         s0rg==
X-Gm-Message-State: APjAAAV4ASXvf9wkM0hGyFKUGLhVg7YBuCF1A+skbEdp/L8/7VboEnez
	Jt1lhGA0l3vLSorsWd2y7gwo9rVCiPcUmF2zdkA=
X-Google-Smtp-Source: APXvYqySasX/x6fK/ZFBF4sNLvCdTUg5vYzZ0ptU0WC1DQqA7ozHIr8NeksPjbfjj3j9Z+i5q/D67EoDgzPair+kAjY=
X-Received: by 2002:a37:8684:: with SMTP id i126mr18173762qkd.433.1567459692698;
 Mon, 02 Sep 2019 14:28:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190830035716.GA190684@LGEARND20B15> <20190830135007.8b5949bd57975d687ff0a3f8@linux-foundation.org>
In-Reply-To: <20190830135007.8b5949bd57975d687ff0a3f8@linux-foundation.org>
From: Austin Kim <austindh.kim@gmail.com>
Date: Tue, 3 Sep 2019 06:28:08 +0900
Message-ID: <CADLLry497WBX0y+y5UuKgSLRjCd+5vbL1qAfUW-U4qsJ8zR6Vg@mail.gmail.com>
Subject: Re: [PATCH] mm/vmalloc: move 'area->pages' after if statement
To: Andrew Morton <akpm@linux-foundation.org>
Cc: urezki@gmail.com, guro@fb.com, rpenyaev@suse.de, mhocko@suse.com, 
	rick.p.edgecombe@intel.com, rppt@linux.ibm.com, aryabinin@virtuozzo.com, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

2019=EB=85=84 8=EC=9B=94 31=EC=9D=BC (=ED=86=A0) =EC=98=A4=EC=A0=84 5:50, A=
ndrew Morton <akpm@linux-foundation.org>=EB=8B=98=EC=9D=B4 =EC=9E=91=EC=84=
=B1:
>
> On Fri, 30 Aug 2019 12:57:16 +0900 Austin Kim <austindh.kim@gmail.com> wr=
ote:
>
> > If !area->pages statement is true where memory allocation fails,
> > area is freed.
> >
> > In this case 'area->pages =3D pages' should not executed.
> > So move 'area->pages =3D pages' after if statement.
> >
> > ...
> >
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2416,13 +2416,15 @@ static void *__vmalloc_area_node(struct vm_stru=
ct *area, gfp_t gfp_mask,
> >       } else {
> >               pages =3D kmalloc_node(array_size, nested_gfp, node);
> >       }
> > -     area->pages =3D pages;
> > -     if (!area->pages) {
> > +
> > +     if (!pages) {
> >               remove_vm_area(area->addr);
> >               kfree(area);
> >               return NULL;
> >       }
> >
> > +     area->pages =3D pages;
> > +
> >       for (i =3D 0; i < area->nr_pages; i++) {
> >               struct page *page;
> >
>
> Fair enough.  But we can/should also do this?

I agreed since it is the same treatment.
Thanks for feedback.

>
> --- a/mm/vmalloc.c~mm-vmalloc-move-area-pages-after-if-statement-fix
> +++ a/mm/vmalloc.c
> @@ -2409,7 +2409,6 @@ static void *__vmalloc_area_node(struct
>         nr_pages =3D get_vm_area_size(area) >> PAGE_SHIFT;
>         array_size =3D (nr_pages * sizeof(struct page *));
>
> -       area->nr_pages =3D nr_pages;
>         /* Please note that the recursion is strictly bounded. */
>         if (array_size > PAGE_SIZE) {
>                 pages =3D __vmalloc_node(array_size, 1, nested_gfp|highme=
m_mask,
> @@ -2425,6 +2424,7 @@ static void *__vmalloc_area_node(struct
>         }
>
>         area->pages =3D pages;
> +       area->nr_pages =3D nr_pages;
>
>         for (i =3D 0; i < area->nr_pages; i++) {
>                 struct page *page;
> _
>

