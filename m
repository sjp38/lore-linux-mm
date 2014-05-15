Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5DEC76B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 17:57:26 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id l4so1291183lbv.17
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:57:25 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id 5si4138168lan.23.2014.05.15.14.57.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 14:57:25 -0700 (PDT)
Received: by mail-lb0-f170.google.com with SMTP id w7so1305367lbi.1
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:57:24 -0700 (PDT)
Date: Fri, 16 May 2014 01:57:22 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140515215722.GU28328@moon>
References: <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon>
 <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon>
 <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon>
 <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
 <20140515201914.GS28328@moon>
 <20140515213124.GT28328@moon>
 <CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXe80dx+ODPF1o2iUMOEOO_JAdev4f9gOQ4SUj4JQv36Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Thu, May 15, 2014 at 02:42:48PM -0700, Andy Lutomirski wrote:
> >
> > Looking forward the question appear -- will VDSO_PREV_PAGES and rest of variables
> > be kind of immutable constants? If yes, we could calculate where the additional
> > vma lives without requiring any kind of [vdso] mark in proc/pid/maps output.
> 
> Please don't!
> 
> These might, in principle, even vary between tasks on the same system.
>  Certainly the relative positions of the vmas will be different
> between 3.15 and 3.16, since we need almost my entire cleanup series
> to reliably put them into their 3.16 location.  And I intend to change
> the number of pages in 3.16 or 3.17.

There are other ways how to find where additional pages are laying but it
would be great if there a straightforward interface for that (ie some mark
in /proc/pid/maps output).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
