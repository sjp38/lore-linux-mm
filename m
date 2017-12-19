Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA5EE6B0283
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:40:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y23so11277484wra.16
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:40:11 -0800 (PST)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.185])
        by mx.google.com with ESMTPS id x56si5326382edm.293.2017.12.19.04.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 04:40:10 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 0/2] mm: introduce MAP_FIXED_SAFE
Date: Tue, 19 Dec 2017 12:40:16 +0000
Message-ID: <0ca2620ce7534c5491e69416621ac41b@AcuMS.aculab.com>
References: <20171213092550.2774-1-mhocko@kernel.org>
 <20171213163210.6a16ccf8753b74a6982ef5b6@linux-foundation.org>
 <CAFLM3-oANXKEU=tuurSJx9rdzfWGfym-0FUEWnfBq8mOaVMzOA@mail.gmail.com>
 <20171214131526.GM16951@dhcp22.suse.cz> <20171214145443.GA2202@brick>
In-Reply-To: <20171214145443.GA2202@brick>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Edward Napierala' <trasz@freebsd.org>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael
 Ellerman <mpe@ellerman.id.au>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John
 Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul
 Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees
 Cook <keescook@chromium.org>, "jasone@google.com" <jasone@google.com>, "davidtgoldblatt@gmail.com" <davidtgoldblatt@gmail.com>

From: Edward Napierala
> Sent: 14 December 2017 14:55
>
> On 1214T1415, Michal Hocko wrote:
> > On Thu 14-12-17 12:44:17, Edward Napierala wrote:
> > > Regarding the name - how about adopting MAP_EXCL?  It was introduced =
in
> > > FreeBSD,
> > > and seems to do exactly this; quoting mmap(2):
> > >
> > > MAP_FIXED    Do not permit the system to select a different address
> > >                         than the one specified.  If the specified add=
ress
> > >                         cannot be used, mmap() will fail.  If MAP_FIX=
ED is
> > >                         specified, addr must be a multiple of the pag=
e size.
> > >                         If MAP_EXCL is not specified, a successful MA=
P_FIXED
> > >                         request replaces any previous mappings for th=
e
> > >                         process' pages in the range from addr to addr=
 + len.
> > >                         In contrast, if MAP_EXCL is specified, the re=
quest
> > >                         will fail if a mapping already exists within =
the
> > >                         range.
> >
> > I am not familiar with the FreeBSD implementation but from the above it
> > looks like MAP_EXCL is a MAP_FIXED mofifier which is not how we are
> > going to implement it in linux due to reasons mentioned in this cover
> > letter. Using the same name would be more confusing than helpful I am
> > afraid.
>=20
> Sorry, missed that.  Indeed, reusing a name with a different semantics
> would be a bad idea.

I don't remember any discussion about using MAP_FIXED | MAP_EXCL ?

Why not match the prior art??

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
