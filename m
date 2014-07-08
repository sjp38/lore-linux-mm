Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id A04BD6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 17:15:09 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so4448158lab.13
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 14:15:08 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id n7si23761847lah.78.2014.07.08.14.15.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 14:15:08 -0700 (PDT)
Received: by mail-lb0-f179.google.com with SMTP id z11so4363623lbi.38
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 14:15:08 -0700 (PDT)
Date: Wed, 9 Jul 2014 01:15:06 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Don't forget to set softdirty on file mapped fault
Message-ID: <20140708211506.GI17860@moon.sw.swsoft.com>
References: <20140708192151.GD17860@moon.sw.swsoft.com>
 <20140708131920.2a857d573e8cc89780c9fa1c@linux-foundation.org>
 <20140708204017.GG17860@moon.sw.swsoft.com>
 <20140708134511.4a32b7400a952541a31e9078@linux-foundation.org>
 <20140708205448.GH17860@moon.sw.swsoft.com>
 <20140708140501.6c293226bfd87e4dff7ef7fb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140708140501.6c293226bfd87e4dff7ef7fb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Jul 08, 2014 at 02:05:01PM -0700, Andrew Morton wrote:
> > 
> > In case if page fault happend on dirty filemapping the newly created pte
> > may loose softdirty bit thus if a userspace program is tracking memory
> > changes with help of a memory tracker (CONFIG_MEM_SOFT_DIRTY) it might
> > miss modification of a memory page (which in worts case may lead to
> > data inconsistency).
> 
> Much better, thanks.
> 
> It's a rather gross-looking bug and data inconsistency sounds serious. 
> Do you think a -stable backport is needed?

It seems the memory tracker is not that widespread in userspace
programs (I mean at the moment as far as I know only we use it
intensively) so I don't consider it as critical but moving it
into stable won't hurt. Still I fear in 3.16 the mm/memory.c
code has been significantly reworked so this patch won't apply
on its own. I can prepare a patch for 3.15 though, just say
a word.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
