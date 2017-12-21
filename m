Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C9816B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 19:26:57 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n13so3299106wmc.3
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:26:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u37si1807158wrb.549.2017.12.20.16.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 16:26:56 -0800 (PST)
Date: Wed, 20 Dec 2017 16:26:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/9] memfd: add sealing to hugetlb-backed memory
Message-Id: <20171220162653.4beeadd43629ccb8a5901aea@linux-foundation.org>
In-Reply-To: <20171220151051.GV4831@dhcp22.suse.cz>
References: <20171107122800.25517-1-marcandre.lureau@redhat.com>
	<aca9951c-7b8a-7884-5b31-c505e4e35d8a@oracle.com>
	<CAJ+F1CJCbmUHSMfKou_LP3eMq+p-b7S9vbe1Vv=JsGMFr7bk_w@mail.gmail.com>
	<20171220151051.GV4831@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?ISO-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@gmail.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com, David Herrmann <dh.herrmann@gmail.com>

On Wed, 20 Dec 2017 16:10:51 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 20-12-17 15:15:50, Marc-Andr=E9 Lureau wrote:
> > Hi
> >=20
> > On Wed, Nov 15, 2017 at 4:13 AM, Mike Kravetz <mike.kravetz@oracle.com>=
 wrote:
> > > +Cc: Andrew, Michal, David
> > >
> > > Are there any other comments on this patch series from Marc-Andr=E9? =
 Is anything
> > > else needed to move forward?
> > >
> > > I have reviewed the patches in the series.  David Herrmann (the origi=
nal
> > > memfd_create/file sealing author) has also taken a look at the patche=
s.
> > >
> > > One outstanding issue is sorting out the config option dependencies. =
 Although,
> > > IMO this is not a strict requirement for this series.  I have address=
ed this
> > > issue in a follow on series:
> > > http://lkml.kernel.org/r/20171109014109.21077-1-mike.kravetz@oracle.c=
om
> >=20
> > Are we good for the next merge window? Is Hugh Dickins the maintainer
> > with the final word, and doing the pull request? (sorry, I am not very
> > familiar with kernel development)
>=20
> Andrew will pick it up, I assume. I will try to get and review this but
> there is way too much going on before holiday.

Yup, things are quiet at present.

I'll suck these up for a bit of testing - please let me know if you'd
prefer them to be held back for a cycle (ie: for 4.17-rc1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
