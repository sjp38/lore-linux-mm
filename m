Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
	by kanga.kvack.org (Postfix) with ESMTP id 80FE56B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 17:43:09 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so2086309veb.20
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:43:09 -0700 (PDT)
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
        by mx.google.com with ESMTPS id gu9si1155447vdc.124.2014.05.15.14.43.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 14:43:08 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id hy4so5094022vcb.25
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:43:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140515213124.GT28328@moon>
References: <5373DBE4.6030907@oracle.com> <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon> <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon> <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon> <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
 <20140515201914.GS28328@moon> <20140515213124.GT28328@moon>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 15 May 2014 14:42:48 -0700
Message-ID: <CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Thu, May 15, 2014 at 2:31 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> On Fri, May 16, 2014 at 12:19:14AM +0400, Cyrill Gorcunov wrote:
>>
>> I see what you mean. We're rather targeting on bare x86-64 at the moment
>> but compat mode is needed as well (not yet implemented though). I'll take
>> a precise look into this area. Thanks!
>
> Indeed, because we were not running 32bit tasks vdso32-setup.c::arch_setup_additional_pages
> has never been called. That's the mode we will have to implement one day.
>
> Looking forward the question appear -- will VDSO_PREV_PAGES and rest of variables
> be kind of immutable constants? If yes, we could calculate where the additional
> vma lives without requiring any kind of [vdso] mark in proc/pid/maps output.

Please don't!

These might, in principle, even vary between tasks on the same system.
 Certainly the relative positions of the vmas will be different
between 3.15 and 3.16, since we need almost my entire cleanup series
to reliably put them into their 3.16 location.  And I intend to change
the number of pages in 3.16 or 3.17.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
