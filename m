Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF16B0039
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 14:12:30 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id fb4so9497085wid.1
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 11:12:30 -0700 (PDT)
Date: Thu, 25 Sep 2014 11:12:26 -0700
From: Zach Brown <zab@zabbo.net>
Subject: Re: [PATCH] aio: Make it possible to remap aio ring
Message-ID: <20140925181226.GM920@lenny.home.zabbo.net>
References: <541B00A1.50003@parallels.com>
 <87eguzuc44.fsf@openvz.org>
 <20140925151316.GO8303@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140925151316.GO8303@kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Dmitry Monakhov <dmonakhov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-aio@kvack.org, Linux MM <linux-mm@kvack.org>

> > > To make restore possible I'm going to mremap() the freshly created ring
> > > into the address A (under which it was seen before dump).

> > > What do you think?
> > Look reasonable.
> > Feel free to add Acked-by:Dmitry Monakhov <dmonakhov@openvz.org>
> > > 
> > > Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> I've had a look over this patch, and it seems okay to me.  The interaction 
> with page migration looks safe, as well as with io_destroy().  I've applied 
> this to my aio-next tree at git://git.kvack.org/~bcrl/aio-next.git .  If 
> mm folks have any concerns, please let me know.

I can chime in with generic support: the C/R folks have complained about
the implicit context mapping in the past.  I'm all for letting them
explicitly re-establish it, though I didn't actually look at the patch.

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
