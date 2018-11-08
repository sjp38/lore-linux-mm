Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BDD26B05FA
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 08:45:56 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id k14-v6so18874490pls.21
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 05:45:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b11-v6sor4995433plb.24.2018.11.08.05.45.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 05:45:55 -0800 (PST)
From: Jongseok Kim <ks77sj@gmail.com>
Subject: Re: [PATCH] z3fold: fix wrong handling of headless pages
Date: Thu,  8 Nov 2018 22:45:40 +0900
Message-Id: <20181108134540.12756-1-ks77sj@gmail.com>
In-Reply-To: <CAMJBoFP3C5NffHf2bPaY-W2qXPLs6z+Ker+Z+Sq_3MHV5xekHQ@mail.gmail.com>
References: <CAMJBoFP3C5NffHf2bPaY-W2qXPLs6z+Ker+Z+Sq_3MHV5xekHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jongseok Kim <ks77sj@gmail.com>

Yes, you are right.
I think that's the best way to deal it.
Thank you.

Best regards,
Jongseok

> Den tors 8 nov. 2018 kl 13:34 skrev +-eA 3/4  1/4 (R) <ks77sj@gmail.com>:
> >
> > Hi Vitaly,
> > thank you for the reply.
> >
> > I agree your a new solution is more comprehensive and drop my patch is simple way.
> > But, I think it's not fair.
> > If my previous patch was not wrong, is (my patch -> your patch) the right way?

> I could apply the new patch on top of yours but that would effectively
> revert most of your changes.
> Would it be ok for you if I add you to Signed-off-by for the new patch instead?

> ~Vitaly


> > I'm sorry I sent reply twice.
> >
> > Best regards,
> > Jongseok
> >
> >
> > > On 6/11/2018 4:48 PM, Vitaly Wool wrote:
> > > Hi Jongseok,
> >
> > > thank you for your work, we've now got a more comprehensive solution:
> > > https://lkml.org/lkml/2018/11/5/726
> >
> > > Would you please confirm that it works for you? Also, would you be
> > >okay with dropping your patch in favor of the new one?
> >
> > > ~Vitaly
