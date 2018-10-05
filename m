Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 13D5B6B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 22:00:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id v7-v6so9682168plo.23
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 19:00:09 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r2-v6si6634489pgk.452.2018.10.04.19.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 19:00:07 -0700 (PDT)
Message-ID: <1538704376.21766.1.camel@intel.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
From: Ley Foon Tan <ley.foon.tan@intel.com>
Date: Fri, 05 Oct 2018 09:52:56 +0800
In-Reply-To: <20181003135257.0b631c30@roar.ozlabs.ibm.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	 <20180923150830.6096-2-npiggin@gmail.com>
	 <20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
	 <1538407463.3190.1.camel@intel.com>
	 <20181003135257.0b631c30@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

On Wed, 2018-10-03 at 13:52 +1000, Nicholas Piggin wrote:
> On Mon, 01 Oct 2018 23:24:23 +0800
> Ley Foon Tan <ley.foon.tan@intel.com> wrote:
>=20
> >=20
> > On Sat, 2018-09-29 at 11:37 +1000, Nicholas Piggin wrote:
> > >=20
> > > Hi,
> > >=20
> > > Did you get a chance to look at these?
> > >=20
> > > This first patch 1/11 solves the lockup problem that Guenter
> > > reported
> > > with my changes to core mm code. So I plan to resubmit my patches
> > > to Andrew's -mm tree with this patch to avoid nios2 breakage.
> > >=20
> > > Thanks,
> > > Nick=C2=A0=C2=A0
> > Do you have git repo that contains these patches? If not, can you
> > send
> > them as attachment to my email?
> Here's a tree with these patches plus 3 of the core mm code changes
> which caused nios2 to hang
>=20
> https://github.com/npiggin/linux/commits/nios2
>=20
Hi Nick

Tested your patches on the github branch. Kernel bootup and ethernet
ping are working.

Regards
Ley Foon
