Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 90BAC6B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 22:01:40 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id h18so8473775igc.12
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:01:40 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id c10si10290465icx.58.2014.07.30.19.01.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 19:01:39 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so4054370igb.16
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 19:01:39 -0700 (PDT)
Date: Wed, 30 Jul 2014 19:01:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] kexec: export free_huge_page to VMCOREINFO fix
In-Reply-To: <CAOesGMgFeg_HNJMfxSzso1e48L+nFPCMqXZAAYKhV02Z29jQBg@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1407301901250.12482@chino.kir.corp.google.com>
References: <53d98399.wRC4T5IRh+/QWqVO%fengguang.wu@intel.com> <alpine.DEB.2.02.1407301727300.12181@chino.kir.corp.google.com> <CAOesGMgFeg_HNJMfxSzso1e48L+nFPCMqXZAAYKhV02Z29jQBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Olof Johansson <olof@lixom.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, kbuild test robot <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 30 Jul 2014, Olof Johansson wrote:

> >  To be folded into kexec-export-free_huge_page-to-vmcoreinfo.patch.
> 
> Looks to be a bit late for that, Linus just merged it. Will need to go
> in as-is instead.
> 

Eeek, that was fast.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
