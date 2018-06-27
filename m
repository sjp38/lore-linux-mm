Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAB326B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:11:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g6-v6so1012407wrp.4
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:11:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j85-v6si3834454wmi.219.2018.06.27.03.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 03:11:55 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5R9xIIf016315
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:11:53 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jv4rmajk6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:11:53 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 27 Jun 2018 11:11:50 +0100
Date: Wed, 27 Jun 2018 13:11:44 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: why do we still need bootmem allocator?
References: <20180625140754.GB29102@dhcp22.suse.cz>
 <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABGGisyVpfYCz7-5AGB-3Ld9hcuikPVk=19xPc1AwffjhsV+kg@mail.gmail.com>
Message-Id: <20180627101144.GC4291@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh@kernel.org>
Cc: mhocko@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Jun 25, 2018 at 10:09:41AM -0600, Rob Herring wrote:
> On Mon, Jun 25, 2018 at 8:08 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > Hi,
> > I am wondering why do we still keep mm/bootmem.c when most architectures
> > already moved to nobootmem. Is there any fundamental reason why others
> > cannot or this is just a matter of work?
> 
> Just because no one has done the work. I did a couple of arches
> recently (sh, microblaze, and h8300) mainly because I broke them with
> some DT changes.

I have a patch for alpha nearly ready.
That leaves m68k and ia64
 
> > Btw. what really needs to be
> > done? Btw. is there any documentation telling us what needs to be done
> > in that regards?
> 
> No. The commits converting the arches are the only documentation. It's
> a bit more complicated for platforms that have NUMA support.
> 
> Rob
> 

-- 
Sincerely yours,
Mike.
