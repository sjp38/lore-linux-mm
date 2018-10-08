Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A71C6B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 03:17:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 8-v6so16373666pfr.0
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 00:17:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj11-v6sor12023588plb.16.2018.10.08.00.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Oct 2018 00:16:58 -0700 (PDT)
Date: Mon, 8 Oct 2018 17:16:52 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
Message-ID: <20181008171652.28fd6824@roar.ozlabs.ibm.com>
In-Reply-To: <1538704376.21766.1.camel@intel.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	<20180923150830.6096-2-npiggin@gmail.com>
	<20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
	<1538407463.3190.1.camel@intel.com>
	<20181003135257.0b631c30@roar.ozlabs.ibm.com>
	<1538704376.21766.1.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <ley.foon.tan@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

On Fri, 05 Oct 2018 09:52:56 +0800
Ley Foon Tan <ley.foon.tan@intel.com> wrote:

> On Wed, 2018-10-03 at 13:52 +1000, Nicholas Piggin wrote:
> > On Mon, 01 Oct 2018 23:24:23 +0800
> > Ley Foon Tan <ley.foon.tan@intel.com> wrote:
> >  =20
> > >=20
> > > On Sat, 2018-09-29 at 11:37 +1000, Nicholas Piggin wrote: =20
> > > >=20
> > > > Hi,
> > > >=20
> > > > Did you get a chance to look at these?
> > > >=20
> > > > This first patch 1/11 solves the lockup problem that Guenter
> > > > reported
> > > > with my changes to core mm code. So I plan to resubmit my patches
> > > > to Andrew's -mm tree with this patch to avoid nios2 breakage.
> > > >=20
> > > > Thanks,
> > > > Nick=C2=A0=C2=A0 =20
> > > Do you have git repo that contains these patches? If not, can you
> > > send
> > > them as attachment to my email? =20
> > Here's a tree with these patches plus 3 of the core mm code changes
> > which caused nios2 to hang
> >=20
> > https://github.com/npiggin/linux/commits/nios2
> >  =20
> Hi Nick
>=20
> Tested your patches on the github branch. Kernel bootup and ethernet
> ping are working.

Hi Ley,

Thank you for testing. I would like to send patch 1 together with my
generic TLB optimisation patches to Andrew. Can I get a Reviewed-by
or ack from you on that?

As to the other nios2 patches, I will leave them to you to merge them
if you want them.

Thanks,
Nick
