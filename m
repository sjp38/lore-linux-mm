Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 701756B003A
	for <linux-mm@kvack.org>; Wed, 14 May 2014 17:31:27 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so127771pab.5
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:31:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id kw10si3150451pab.50.2014.05.14.14.31.26
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 14:31:26 -0700 (PDT)
Date: Wed, 14 May 2014 14:31:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-Id: <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
In-Reply-To: <5373DBE4.6030907@oracle.com>
References: <53739201.6080604@oracle.com>
	<20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
	<5373D509.7090207@oracle.com>
	<20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
	<5373DBE4.6030907@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>

On Wed, 14 May 2014 17:11:00 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> > In my linux-next all that code got deleted by Andy's "x86, vdso:
> > Reimplement vdso.so preparation in build-time C" anyway.  What kernel
> > were you looking at?
> 
> Deleted? It appears in today's -next. arch/x86/vdso/vma.c:124 .
> 
> I don't see Andy's patch removing that code either.

ah, OK, it got moved from arch/x86/vdso/vdso32-setup.c into
arch/x86/vdso/vma.c.

Maybe you managed to take a fault against the symbol area between the
_install_special_mapping() and the remap_pfn_range() call, but mmap_sem
should prevent that.

Or the remap_pfn_range() call never happened.  Should map_vdso() be
running _install_special_mapping() at all if
image->sym_vvar_page==NULL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
