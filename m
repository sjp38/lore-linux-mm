Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3EB6B0005
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:47:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b25-v6so1809609eds.17
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:47:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h2-v6si3258054eds.21.2018.07.18.04.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 04:47:42 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6IBhkVS006090
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:47:40 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ka2xvwc22-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:47:40 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Jul 2018 12:47:35 +0100
Date: Wed, 18 Jul 2018 14:47:30 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180702113255.1f7504e2@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702113255.1f7504e2@lwn.net>
Message-Id: <20180718114730.GD4302@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi,

On Mon, Jul 02, 2018 at 11:32:55AM -0600, Jonathan Corbet wrote:
> On Sat, 30 Jun 2018 17:54:55 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > Both bootmem and memblock have pretty good documentation coverage. With
> > some fixups and additions we get a nice overall description.
> > 
> > v2 changes:
> > * address Randy's comments
> > 
> > Mike Rapoport (11):
> >   mm/bootmem: drop duplicated kernel-doc comments
> >   docs/mm: nobootmem: fixup kernel-doc comments
> >   docs/mm: bootmem: fix kernel-doc warnings
> >   docs/mm: bootmem: add kernel-doc description of 'struct bootmem_data'
> >   docs/mm: bootmem: add overview documentation
> >   mm/memblock: add a name for memblock flags enumeration
> >   docs/mm: memblock: update kernel-doc comments
> >   docs/mm: memblock: add kernel-doc comments for memblock_add[_node]
> >   docs/mm: memblock: add kernel-doc description for memblock types
> >   docs/mm: memblock: add overview documentation
> >   docs/mm: add description of boot time memory management
> 
> So this seems like good stuff overall.  It digs pretty deeply into the mm
> code, though, so I'm a little reluctant to apply it without an ack from an
> mm developer.  Alternatively, I'm happy to step back if Andrew wants to
> pick the set up.

Jon, does Michal's reply [1] address your concerns?
Or should I respin and ask Andrew to pick it up? 

[1] https://lore.kernel.org/lkml/20180712080006.GA328@dhcp22.suse.cz/
> Thanks,
> 
> jon
> 

-- 
Sincerely yours,
Mike.
