Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E7C636B05F7
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 07:57:30 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id h10-v6so5899077ljk.18
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 04:57:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o22-v6sor2533407lji.38.2018.11.08.04.57.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 04:57:29 -0800 (PST)
MIME-Version: 1.0
References: <1530853846-30215-1-git-send-email-ks77sj@gmail.com>
 <CAMJBoFPGZ_pYFQTXb06U4QxM1ibUhmdxr6efwZigXdUo=4S=Vw@mail.gmail.com> <CALbL15bGHL_M=ofWy_VrDZU_7b2DOC7BnpqJ63gfQ_1gNcG_9A@mail.gmail.com>
In-Reply-To: <CALbL15bGHL_M=ofWy_VrDZU_7b2DOC7BnpqJ63gfQ_1gNcG_9A@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 8 Nov 2018 13:57:17 +0100
Message-ID: <CAMJBoFP3C5NffHf2bPaY-W2qXPLs6z+Ker+Z+Sq_3MHV5xekHQ@mail.gmail.com>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?6rmA7KKF7ISd?= <ks77sj@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Den tors 8 nov. 2018 kl 13:34 skrev =EA=B9=80=EC=A2=85=EC=84=9D <ks77sj@gma=
il.com>:
>
> Hi Vitaly,
> thank you for the reply.
>
> I agree your a new solution is more comprehensive and drop my patch is si=
mple way.
> But, I think it's not fair.
> If my previous patch was not wrong, is (my patch -> your patch) the right=
 way?

I could apply the new patch on top of yours but that would effectively
revert most of your changes.
Would it be ok for you if I add you to Signed-off-by for the new patch inst=
ead?

~Vitaly

> I'm sorry I sent reply twice.
>
> Best regards,
> Jongseok
>
>
> > On 6/11/2018 4:48 PM, Vitaly Wool wrote:
> > Hi Jongseok,
>
> > thank you for your work, we've now got a more comprehensive solution:
> > https://lkml.org/lkml/2018/11/5/726
>
> > Would you please confirm that it works for you? Also, would you be
> >okay with dropping your patch in favor of the new one?
>
> > ~Vitaly
