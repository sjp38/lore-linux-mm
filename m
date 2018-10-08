Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A61C86B000D
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 05:21:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 11-v6so10363115pgd.1
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 02:21:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d71-v6sor2500103pfj.27.2018.10.08.02.21.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 02:21:49 -0700 (PDT)
Date: Mon, 8 Oct 2018 19:21:42 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
Message-ID: <20181008192142.26d6d4fb@roar.ozlabs.ibm.com>
In-Reply-To: <1539018138.2486.4.camel@intel.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	<20180923150830.6096-2-npiggin@gmail.com>
	<20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
	<1538407463.3190.1.camel@intel.com>
	<20181003135257.0b631c30@roar.ozlabs.ibm.com>
	<1538704376.21766.1.camel@intel.com>
	<20181008171652.28fd6824@roar.ozlabs.ibm.com>
	<1539018138.2486.4.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <ley.foon.tan@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

On Tue, 09 Oct 2018 01:02:18 +0800
Ley Foon Tan <ley.foon.tan@intel.com> wrote:

> On Mon, 2018-10-08 at 17:16 +1000, Nicholas Piggin wrote:
> > On Fri, 05 Oct 2018 09:52:56 +0800
> > Ley Foon Tan <ley.foon.tan@intel.com> wrote:
> >  =20
> > >=20
> > > On Wed, 2018-10-03 at 13:52 +1000, Nicholas Piggin wrote: =20
> > > >=20
> > > > On Mon, 01 Oct 2018 23:24:23 +0800
> > > > Ley Foon Tan <ley.foon.tan@intel.com> wrote:
> > > > =C2=A0=C2=A0 =20
> > > > >=20
> > > > >=20
> > > > > On Sat, 2018-09-29 at 11:37 +1000, Nicholas Piggin wrote:=C2=A0=
=C2=A0 =20
> > > > > >=20
> > > > > >=20
> > > > > > Hi,
> > > > > >=20
> > > > > > Did you get a chance to look at these?
> > > > > >=20
> > > > > > This first patch 1/11 solves the lockup problem that Guenter
> > > > > > reported
> > > > > > with my changes to core mm code. So I plan to resubmit my
> > > > > > patches
> > > > > > to Andrew's -mm tree with this patch to avoid nios2 breakage.
> > > > > >=20
> > > > > > Thanks,
> > > > > > Nick=C2=A0=C2=A0=C2=A0=C2=A0 =20
> > > > > Do you have git repo that contains these patches? If not, can
> > > > > you
> > > > > send
> > > > > them as attachment to my email?=C2=A0=C2=A0 =20
> > > > Here's a tree with these patches plus 3 of the core mm code
> > > > changes
> > > > which caused nios2 to hang
> > > >=20
> > > > https://github.com/npiggin/linux/commits/nios2
> > > > =C2=A0=C2=A0 =20
> > > Hi Nick
> > >=20
> > > Tested your patches on the github branch. Kernel bootup and
> > > ethernet
> > > ping are working. =20
> > Hi Ley,
> >=20
> > Thank you for testing. I would like to send patch 1 together with my
> > generic TLB optimisation patches to Andrew. Can I get a Reviewed-by
> > or ack from you on that? =20
> For that series,
> Reviewed-by: Ley Foon Tan <ley.foon.tan@intel.com>

Thank you, I will use it for patch 1 if necessary

>=20
> >=20
> > As to the other nios2 patches, I will leave them to you to merge them
> > if you want them. =20
> I can merge these nios2 patches. BTW, any dependency between these
> nios2 patches with the generic TLB optimisation patches? e.g: patch
> applying sequence.

That would be good. The only dependency is that the generic TLB patches
depend on nios2 patch 1, so you should be able to take them and merge
them now. I will have to take care of the patch 1 dependency when
submitting the generic TLB patches.

Thanks,
Nick


>=20
>=20
> Regards
> Ley Foon
>=20
