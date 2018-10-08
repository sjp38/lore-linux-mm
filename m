Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A08D06B000A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 05:02:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 87-v6so16334374pfq.8
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 02:02:54 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id g22-v6si16167133pgg.575.2018.10.08.02.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 02:02:53 -0700 (PDT)
Message-ID: <1539018138.2486.4.camel@intel.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
From: Ley Foon Tan <ley.foon.tan@intel.com>
Date: Tue, 09 Oct 2018 01:02:18 +0800
In-Reply-To: <20181008171652.28fd6824@roar.ozlabs.ibm.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	 <20180923150830.6096-2-npiggin@gmail.com>
	 <20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
	 <1538407463.3190.1.camel@intel.com>
	 <20181003135257.0b631c30@roar.ozlabs.ibm.com>
	 <1538704376.21766.1.camel@intel.com>
	 <20181008171652.28fd6824@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

On Mon, 2018-10-08 at 17:16 +1000, Nicholas Piggin wrote:
> On Fri, 05 Oct 2018 09:52:56 +0800
> Ley Foon Tan <ley.foon.tan@intel.com> wrote:
>=20
> >=20
> > On Wed, 2018-10-03 at 13:52 +1000, Nicholas Piggin wrote:
> > >=20
> > > On Mon, 01 Oct 2018 23:24:23 +0800
> > > Ley Foon Tan <ley.foon.tan@intel.com> wrote:
> > > =C2=A0=C2=A0
> > > >=20
> > > >=20
> > > > On Sat, 2018-09-29 at 11:37 +1000, Nicholas Piggin wrote:=C2=A0=C2=
=A0
> > > > >=20
> > > > >=20
> > > > > Hi,
> > > > >=20
> > > > > Did you get a chance to look at these?
> > > > >=20
> > > > > This first patch 1/11 solves the lockup problem that Guenter
> > > > > reported
> > > > > with my changes to core mm code. So I plan to resubmit my
> > > > > patches
> > > > > to Andrew's -mm tree with this patch to avoid nios2 breakage.
> > > > >=20
> > > > > Thanks,
> > > > > Nick=C2=A0=C2=A0=C2=A0=C2=A0
> > > > Do you have git repo that contains these patches? If not, can
> > > > you
> > > > send
> > > > them as attachment to my email?=C2=A0=C2=A0
> > > Here's a tree with these patches plus 3 of the core mm code
> > > changes
> > > which caused nios2 to hang
> > >=20
> > > https://github.com/npiggin/linux/commits/nios2
> > > =C2=A0=C2=A0
> > Hi Nick
> >=20
> > Tested your patches on the github branch. Kernel bootup and
> > ethernet
> > ping are working.
> Hi Ley,
>=20
> Thank you for testing. I would like to send patch 1 together with my
> generic TLB optimisation patches to Andrew. Can I get a Reviewed-by
> or ack from you on that?
For that series,
Reviewed-by: Ley Foon Tan <ley.foon.tan@intel.com>

>=20
> As to the other nios2 patches, I will leave them to you to merge them
> if you want them.
I can merge these nios2 patches. BTW, any dependency between these
nios2 patches with the generic TLB optimisation patches? e.g: patch
applying sequence.


Regards
Ley Foon
