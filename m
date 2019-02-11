Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 197C8C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:37:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C23FB218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:37:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="SqiX0il2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C23FB218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 737E08E0100; Mon, 11 Feb 2019 11:37:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E6218E00F6; Mon, 11 Feb 2019 11:37:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FCA58E0100; Mon, 11 Feb 2019 11:37:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35F2E8E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:37:54 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id n22so11458509otq.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:37:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=y+WgygOtpVO0gM+ieHP6u5F87v+TX254wZk88lkZFfs=;
        b=i0Rr/CN/wGCJU2kNC3l8CWtXvGcm2cKjXSpbhWUaAZxmG23nozdZ+EZ3gAyavci803
         fQCLTfaFlww/819NCgaTYeZbgElb9RhfcoQkMiN5j2xigX1lA2JmUE9p+l3osKbASHLV
         UJeZmT4QwDtUg7zpYrQ42WzZ+C2R9t97SVqqDwKtwRcF+mppMqxO+bCIIof6tylT74OY
         KzsaoRsPU+sXplamW0ENzwvmD+3KsnpcJwbamF2tGN5bwxrjY9Z0RxxSu6sKC1PCpJH9
         Y5U1tKDVF8BIYQM8zp5B1A3BsM8jRWK8exmrec9KNzQOF/lnNlKROzVBT9vGk9L7rNEQ
         jiOQ==
X-Gm-Message-State: AHQUAuYc3d1zJq7gWo12wDKAsZlgvH1w7drY5v6drUk0FqAkPAIKm6bo
	sXA4Wyt8L5LJHydZHO37rRYgwOklE0jh3QV2dWB6yRWdwnsiNlb7pFlb9G4Xd07TWXlXcYDfZhR
	Jcs+2buAwq4P4Y2rQ6Tvwp1pOXArcZJMjyp7IO1I1gMFIVYJFplA/hPAAbx7+bG9Nbiyrns9vh7
	wXAM5DQvjcXFN0enZL1UlVS+wvxyLBl1unJGqzWEB6xIfTzkEIcoBswB/0sJjic0L76OxOROC6O
	ihVFP663Zj/NqMNGWnWGZscLsI2n16sJpFXt7hPjNNLZST9JORso68Jbh9MGDajgWZe8x3+fnN4
	467bi869nNZlsWDGL2UTTp6Ob8Y4xVMwwYwPkX0H4ojjcDOsYqY0MywIxsLn5sWZ81mt6so9oez
	I
X-Received: by 2002:a9d:137:: with SMTP id 52mr29119084otu.307.1549903073757;
        Mon, 11 Feb 2019 08:37:53 -0800 (PST)
X-Received: by 2002:a9d:137:: with SMTP id 52mr29119014otu.307.1549903072909;
        Mon, 11 Feb 2019 08:37:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549903072; cv=none;
        d=google.com; s=arc-20160816;
        b=QJUWlnZ6mMMpLSqQzUmJl3ToydwgwWSKGpQzermEoPQNJVLJvKiC6pZPDy1BasVOEH
         hyYteV9BVc089rXQ8BwT1COa06UDaBFU+FnUoA/ntX7CBv+riQ629fzJ9eblo7/vjz+0
         PFfPwzDFsnNPof1BUCZACXyNUupmsMbcVtiLpRjYTX6sQnuaqrUzwi2U0F0knaLBaNBp
         Z9duR5RxN44sOPqH0/RPfPPZAW/WiG5YVFH5rk4Ru8LfmpRlvoopPdMmx8HhIcP2Y394
         Xo9u89wha2Z/7BM/5raObgVxvUIP3xA5/objC2bcKZQBPoFCo7ioJP/2HdkllSEWmMon
         iNMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=y+WgygOtpVO0gM+ieHP6u5F87v+TX254wZk88lkZFfs=;
        b=YDCljH9WIq+PoIAu4362zSetr+Io3ArzDCdnw/MO4nVa4IJw3/SEgsd8MBrX9kSGr6
         cXF/AuqehJzOz9ZbAq7M6J66jNETu2HjkRUIhCU4Xs/ZwnPdrFhXT3pjGZbqynVn1rd/
         fE/p1aNoUCON/xw1DTe4VvLknjxekTKM4/fNJTOpvYzH+MiTQB6InaNKguizKg4lsIfB
         1qFhcLSlEu+6N4GJx3NRAvFaNgyNDW6wt5Rfqn805McYlUq/O3Agq/dLlD0qj85bWLci
         T46drgTR1VF+tGI8A16jL5qiDJL6Dr8K9dkfxQ86wHJVt2tBdOBhsRyG8uLLgFwRJaNo
         pqaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SqiX0il2;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 60sor6546273otg.147.2019.02.11.08.37.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 08:37:52 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SqiX0il2;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=y+WgygOtpVO0gM+ieHP6u5F87v+TX254wZk88lkZFfs=;
        b=SqiX0il20523leaUZO7Dw38Xu6z7Ct3I5gNH6tsjk3SOor7NXieso6+6knlODFRARF
         +MHzR/xdvbH+lUfNPEsFyVg87HaKR4Gi14Mow0TyNFpvFS83EiuNkX6ZoiBUzVAgH6sF
         RAjC4zMoteQ3fN9s64bFKc0qhLk/MjDv8y8oewpW+lS8EqpgtCsh2H6V9/M5+n/p6Hi/
         jdQVVb88/YWQfTQG8G9M/fBD6MAQR9wHHheEu6OMHlGl2XiHlN3Ivecg9a9V+RM18GNi
         5D5HZ6heq54TbMRG21sWsB9jDVp/9nMCp5aoaQ+PxIOeedIkU3FXKZ87AdUZ4/VhL/T8
         cQDA==
X-Google-Smtp-Source: AHgI3IabdQ7lZF57qC2GpDfHRURDHsO3iu0cds0tRnOd/QNyPhKQ0SKinNYmkBta3EuPU4wOk+GFAYAvwsMC+Gaa09Y=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr12257432ota.229.1549903072090;
 Mon, 11 Feb 2019 08:37:52 -0800 (PST)
MIME-Version: 1.0
References: <20190207053740.26915-1-dave@stgolabs.net> <20190207053740.26915-2-dave@stgolabs.net>
 <CAJ+HfNg=Wikc_uY9W1QiVCONq3c1GyS44-xbrq-J4gqfth2kwQ@mail.gmail.com> <d92b7b49-81e6-1ac5-4ae4-4909f87bbea8@iogearbox.net>
In-Reply-To: <d92b7b49-81e6-1ac5-4ae4-4909f87bbea8@iogearbox.net>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 08:37:41 -0800
Message-ID: <CAPcyv4gjUmRdV1jZegLecocj155m7dpQLxQSnF_HQQErD8Gtag@mail.gmail.com>
Subject: Re: [PATCH 1/2] xsk: do not use mmap_sem
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@gmail.com>, 
	Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	"David S . Miller" <davem@davemloft.net>, Bjorn Topel <bjorn.topel@intel.com>, 
	Magnus Karlsson <magnus.karlsson@intel.com>, Netdev <netdev@vger.kernel.org>, 
	Davidlohr Bueso <dbueso@suse.de>, "Weiny, Ira" <ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Ira ]

On Mon, Feb 11, 2019 at 7:33 AM Daniel Borkmann <daniel@iogearbox.net> wrot=
e:
>
> [ +Dan ]
>
> On 02/07/2019 08:43 AM, Bj=C3=B6rn T=C3=B6pel wrote:
> > Den tors 7 feb. 2019 kl 06:38 skrev Davidlohr Bueso <dave@stgolabs.net>=
:
> >>
> >> Holding mmap_sem exclusively for a gup() is an overkill.
> >> Lets replace the call for gup_fast() and let the mm take
> >> it if necessary.
> >>
> >> Cc: David S. Miller <davem@davemloft.net>
> >> Cc: Bjorn Topel <bjorn.topel@intel.com>
> >> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> >> CC: netdev@vger.kernel.org
> >> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> >> ---
> >>  net/xdp/xdp_umem.c | 6 ++----
> >>  1 file changed, 2 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> >> index 5ab236c5c9a5..25e1e76654a8 100644
> >> --- a/net/xdp/xdp_umem.c
> >> +++ b/net/xdp/xdp_umem.c
> >> @@ -265,10 +265,8 @@ static int xdp_umem_pin_pages(struct xdp_umem *um=
em)
> >>         if (!umem->pgs)
> >>                 return -ENOMEM;
> >>
> >> -       down_write(&current->mm->mmap_sem);
> >> -       npgs =3D get_user_pages(umem->address, umem->npgs,
> >> -                             gup_flags, &umem->pgs[0], NULL);
> >> -       up_write(&current->mm->mmap_sem);
> >> +       npgs =3D get_user_pages_fast(umem->address, umem->npgs,
> >> +                                  gup_flags, &umem->pgs[0]);
> >>
> >
> > Thanks for the patch!
> >
> > The lifetime of the pinning is similar to RDMA umem mapping, so isn't
> > gup_longterm preferred?
>
> Seems reasonable from reading what gup_longterm seems to do. Davidlohr
> or Dan, any thoughts on the above?

Yes, any gup where the lifetime of the corresponding put_page() is
under direct control of userspace should be using the _longterm flavor
to coordinate be careful in the presence of dax. In the dax case there
is no page cache indirection to coordinate truncate vs page pins. Ira
is looking to add a "fast + longterm" flavor for cases like this.

