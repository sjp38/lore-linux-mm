Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CB1216B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 09:58:32 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id z5-v6so1272014pln.20
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:58:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n1-v6si3500208pge.263.2018.06.27.06.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 06:58:31 -0700 (PDT)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1EA6D265E2
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 13:58:31 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id 16-v6so7669151itl.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:58:31 -0700 (PDT)
MIME-Version: 1.0
References: <20180625140754.GB29102@dhcp22.suse.cz> <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
 <20180627101144.GC4291@rapoport-lnx>
In-Reply-To: <20180627101144.GC4291@rapoport-lnx>
From: Rob Herring <robh@kernel.org>
Date: Wed, 27 Jun 2018 07:58:19 -0600
Message-ID: <CAL_Jsq+evsgh9Qi6FfG4vUZWtpC0UrFjTWSrzukMxY==TD_mrg@mail.gmail.com>
Subject: Re: why do we still need bootmem allocator?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2018 at 4:11 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
>
> On Mon, Jun 25, 2018 at 10:09:41AM -0600, Rob Herring wrote:
> > On Mon, Jun 25, 2018 at 8:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > Hi,
> > > I am wondering why do we still keep mm/bootmem.c when most architectures
> > > already moved to nobootmem. Is there any fundamental reason why others
> > > cannot or this is just a matter of work?
> >
> > Just because no one has done the work. I did a couple of arches
> > recently (sh, microblaze, and h8300) mainly because I broke them with
> > some DT changes.
>
> I have a patch for alpha nearly ready.
> That leaves m68k and ia64

And c6x, hexagon, mips, nios2, unicore32. Those are all the platforms
which don't select NO_BOOTMEM.

Rob
