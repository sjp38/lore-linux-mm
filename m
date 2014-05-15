Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 979D86B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 16:19:17 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id el20so1229719lab.15
        for <linux-mm@kvack.org>; Thu, 15 May 2014 13:19:17 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id q5si4009564lah.122.2014.05.15.13.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 13:19:16 -0700 (PDT)
Received: by mail-lb0-f181.google.com with SMTP id u14so1197709lbd.40
        for <linux-mm@kvack.org>; Thu, 15 May 2014 13:19:15 -0700 (PDT)
Date: Fri, 16 May 2014 00:19:14 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140515201914.GS28328@moon>
References: <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com>
 <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon>
 <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <20140515084558.GI28328@moon>
 <CALCETrWwWXEoNparvhx4yJB8YmiUBZCuR6yQxJOTjYKuA8AdqQ@mail.gmail.com>
 <20140515195320.GR28328@moon>
 <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWbf8XYvBh=zdyOBqVqRd7s8SVbbDX=O2X+zAZn83r-bw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Thu, May 15, 2014 at 12:59:04PM -0700, Andy Lutomirski wrote:
> >>
> >> What version and bitness is this?
> >
> > x86-64, 3.15-rc5
> 
> Aha.  Give tip/x86/vdso or -next a try or boot a 32-bit 3.15-rc kernel
> and you'll see it.

I see what you mean. We're rather targeting on bare x86-64 at the moment
but compat mode is needed as well (not yet implemented though). I'll take
a precise look into this area. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
