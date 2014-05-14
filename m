Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6B18B6B003A
	for <linux-mm@kvack.org>; Wed, 14 May 2014 17:34:15 -0400 (EDT)
Received: by mail-ve0-f172.google.com with SMTP id oz11so216385veb.17
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:34:15 -0700 (PDT)
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
        by mx.google.com with ESMTPS id iq2si540555veb.181.2014.05.14.14.34.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 14:34:14 -0700 (PDT)
Received: by mail-ve0-f171.google.com with SMTP id oz11so218086veb.16
        for <linux-mm@kvack.org>; Wed, 14 May 2014 14:34:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
References: <53739201.6080604@oracle.com> <20140514132312.573e5d3cf99276c3f0b82980@linux-foundation.org>
 <5373D509.7090207@oracle.com> <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com> <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 14 May 2014 14:33:54 -0700
Message-ID: <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>

On Wed, May 14, 2014 at 2:31 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 14 May 2014 17:11:00 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:
>
>> > In my linux-next all that code got deleted by Andy's "x86, vdso:
>> > Reimplement vdso.so preparation in build-time C" anyway.  What kernel
>> > were you looking at?
>>
>> Deleted? It appears in today's -next. arch/x86/vdso/vma.c:124 .
>>
>> I don't see Andy's patch removing that code either.
>
> ah, OK, it got moved from arch/x86/vdso/vdso32-setup.c into
> arch/x86/vdso/vma.c.
>
> Maybe you managed to take a fault against the symbol area between the
> _install_special_mapping() and the remap_pfn_range() call, but mmap_sem
> should prevent that.
>
> Or the remap_pfn_range() call never happened.  Should map_vdso() be
> running _install_special_mapping() at all if
> image->sym_vvar_page==NULL?

I'm confused: are we talking about 3.15-rcsomething or linux-next?
That code changed.

Would this all make more sense if there were just a single vma in
here?  cc: Pavel and Cyrill, who might have to deal with this stuff in
CRIU

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
