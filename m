Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 96D02280303
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:40:42 -0400 (EDT)
Received: by qgii95 with SMTP id i95so6509396qgi.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:40:42 -0700 (PDT)
Date: Thu, 16 Jul 2015 21:38:56 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [mmotm:master 140/321] fs/built-in.o:undefined reference to
	`filemap_page_mkwrite'
Message-ID: <20150716193856.GA25255@redhat.com>
References: <201507160919.VRGXvreQ%fengguang.wu@intel.com> <20150716190503.GA22146@redhat.com> <20150716191258.GA22760@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150716191258.GA22760@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Jeff Moyer <jmoyer@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On 07/16, Benjamin LaHaise wrote:
>
> On Thu, Jul 16, 2015 at 09:05:03PM +0200, Oleg Nesterov wrote:
> > Thanks!
> ...
> > but the problem looks clear: CONFIG_MMU is not set, so we need
> > a dummy filemap_page_mkwrite() along with generic_file_mmap() and
> > generic_file_readonly_mmap().
> >
> > I'll send the fix, but...
> >
> > Benjamin, Jeff, shouldn't AIO depend on MMU? Or it can actually work even
> > if CONFIG_MMU=n?
>
> It should work when CONFIG_MMU=n,

Really? I am just curious.

alloc_anon_inode() doesn't set S_IFREG, it seems that nommu.c:do_mmap_pgoff()
should just fail in validate_mmap_request() ?

Even if not, it should fail because of MAP_SHARED && !NOMMU_MAP_DIRECT?

I am just trying to understand, could you explain?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
