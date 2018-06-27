Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B4BF6B0008
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:58:23 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a3-v6so1503866wrr.12
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 08:58:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j98-v6si5023928wrj.322.2018.06.27.08.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 08:58:22 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5RFs54Y143069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:58:21 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jvd219s56-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 11:58:20 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 16:58:18 +0100
Date: Wed, 27 Jun 2018 18:58:12 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: why do we still need bootmem allocator?
References: <20180625140754.GB29102@dhcp22.suse.cz>
 <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
 <20180627101144.GC4291@rapoport-lnx>
 <CAL_Jsq+evsgh9Qi6FfG4vUZWtpC0UrFjTWSrzukMxY==TD_mrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL_Jsq+evsgh9Qi6FfG4vUZWtpC0UrFjTWSrzukMxY==TD_mrg@mail.gmail.com>
Message-Id: <20180627155811.GA19182@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh@kernel.org>
Cc: mhocko@kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "open list:GENERIC INCLUDE/ASM HEADER FILES" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2018 at 07:58:19AM -0600, Rob Herring wrote:
> On Wed, Jun 27, 2018 at 4:11 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> >
> > On Mon, Jun 25, 2018 at 10:09:41AM -0600, Rob Herring wrote:
> > > On Mon, Jun 25, 2018 at 8:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > >
> > > > Hi,
> > > > I am wondering why do we still keep mm/bootmem.c when most architectures
> > > > already moved to nobootmem. Is there any fundamental reason why others
> > > > cannot or this is just a matter of work?
> > >
> > > Just because no one has done the work. I did a couple of arches
> > > recently (sh, microblaze, and h8300) mainly because I broke them with
> > > some DT changes.
> >
> > I have a patch for alpha nearly ready.
> > That leaves m68k and ia64
> 
> And c6x, hexagon, mips, nios2, unicore32. Those are all the platforms
> which don't select NO_BOOTMEM.

Yeah, you are right. I've somehow excluded those that HAVE_MEMBLOCK...
 
> Rob
> 

-- 
Sincerely yours,
Mike.
