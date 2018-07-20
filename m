Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFBD96B000A
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:30:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r2-v6so6590269pgp.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:30:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n10-v6si2562955pfb.316.2018.07.20.12.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jul 2018 12:30:20 -0700 (PDT)
Date: Fri, 20 Jul 2018 12:30:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm/memblock: add missing include <linux/bootmem.h>
Message-Id: <20180720123018.0a7b4ea3a5c848e1a63750aa@linux-foundation.org>
In-Reply-To: <CA+8MBbLB5JTdcgS3yJRR12doMgEiofD8NNXedyYyj4c7AcDnMg@mail.gmail.com>
References: <20180625171513.31845-1-malat@debian.org>
	<20180626184422.24974-1-malat@debian.org>
	<CA+8MBbLB5JTdcgS3yJRR12doMgEiofD8NNXedyYyj4c7AcDnMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Mathieu Malaterre <malat@debian.org>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, 20 Jul 2018 12:16:05 -0700 Tony Luck <tony.luck@gmail.com> wrote:

> On Tue, Jun 26, 2018 at 11:44 AM, Mathieu Malaterre <malat@debian.org> wrote:
> > Because Makefile already does:
> >
> >   obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
> >
> > The #ifdef has been simplified from:
> >
> >   #if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
> >
> > to simply:
> >
> >   #if defined(CONFIG_NO_BOOTMEM)
> 
> Is this sitting in a queue somewhere ready to go to Linus?

linux-next ;)

> I don't see it upstream yet.

For some brainfarty reason I had it for 4.19-rc1.  Shall send it in
today.
