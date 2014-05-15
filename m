Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3107B6B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 17:31:28 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so1258235lbi.23
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:31:27 -0700 (PDT)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id p17si4105237laa.66.2014.05.15.14.31.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 14:31:26 -0700 (PDT)
Received: by mail-lb0-f177.google.com with SMTP id s7so1261700lbd.36
        for <linux-mm@kvack.org>; Thu, 15 May 2014 14:31:25 -0700 (PDT)
Date: Fri, 16 May 2014 01:31:24 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140515213124.GT28328@moon>
References: <5373DBE4.6030907@oracle.com>
 <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon>
 <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon>
 <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon>
 <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
 <20140515201914.GS28328@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140515201914.GS28328@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Fri, May 16, 2014 at 12:19:14AM +0400, Cyrill Gorcunov wrote:
> 
> I see what you mean. We're rather targeting on bare x86-64 at the moment
> but compat mode is needed as well (not yet implemented though). I'll take
> a precise look into this area. Thanks!

Indeed, because we were not running 32bit tasks vdso32-setup.c::arch_setup_additional_pages
has never been called. That's the mode we will have to implement one day.

Looking forward the question appear -- will VDSO_PREV_PAGES and rest of variables
be kind of immutable constants? If yes, we could calculate where the additional
vma lives without requiring any kind of [vdso] mark in proc/pid/maps output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
