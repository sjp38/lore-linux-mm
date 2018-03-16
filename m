Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8586B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:35:40 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bb5-v6so6170258plb.22
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:35:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c12-v6si6972112plo.278.2018.03.16.14.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:35:39 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:35:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/14] mm/hmm: fix header file if/else/endif maze
Message-Id: <20180316143537.0d49a76ec48ec0ab034af93b@linux-foundation.org>
In-Reply-To: <20180316211801.GB4861@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
	<20180316191414.3223-3-jglisse@redhat.com>
	<20180316140959.b603888e2a9ba2e42e56ba1f@linux-foundation.org>
	<20180316211801.GB4861@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

On Fri, 16 Mar 2018 17:18:02 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> On Fri, Mar 16, 2018 at 02:09:59PM -0700, Andrew Morton wrote:
> > On Fri, 16 Mar 2018 15:14:07 -0400 jglisse@redhat.com wrote:
> >=20
> > > From: J=E9r=F4me Glisse <jglisse@redhat.com>
> > >=20
> > > The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong.
> >=20
> > "were wrong" is not a sufficient explanation of the problem, especially
> > if we're requesting a -stable backport.  Please fully describe the
> > effects of a bug when fixing it?
>=20
> Build issue (compilation failure) if you have multiple includes of
> hmm.h through different headers is the most obvious issue. So it
> will be very obvious with any big driver that include the file in
> different headers.

That doesn't seem to warrant a -stable backport?  The developer of such
a driver will simply fix the headers?

> I can respin with that. Sorry again for not being more explanatory
> it is always hard for me to figure what is not obvious to others.

I updated the changelog, no respin needed.
