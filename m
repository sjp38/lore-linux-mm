Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 016C16B02D3
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 11:48:38 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p190so36474960wmp.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 08:48:37 -0700 (PDT)
Received: from sipsolutions.net (s3.sipsolutions.net. [5.9.151.49])
        by mx.google.com with ESMTPS id a198si10215879wmd.130.2016.11.03.08.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Nov 2016 08:48:36 -0700 (PDT)
Message-ID: <1478188108.4041.7.camel@sipsolutions.net>
Subject: Re: [RFC] make kmemleak scan __ro_after_init section (was: Re:
 [PATCH 0/5] genetlink improvements)
From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 03 Nov 2016 16:48:28 +0100
In-Reply-To: <20161102234755.4381f528@jkicinski-Precision-T1700>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
	 <20161101172840.6d7d6278@jkicinski-Precision-T1700>
	 <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
	 <20161101185630.3c7d326f@jkicinski-Precision-T1700>
	 <CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
	 <20161102234755.4381f528@jkicinski-Precision-T1700>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jakub Kicinski <kubakici@wp.pl>, Cong Wang <xiyou.wangcong@gmail.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org

Hi,

Sorry for not chipping in earlier - LPC is taking my time.

> > > > Looks like we are missing a kfree(family->attrbuf); on error
> > > > path, but it is not related to Johannes' recent patches.

Actually, I think it *is* related to my patch - I inserted the code
there in the wrong place or so. I'll find a fix for that when I'm back
home, or you (Cong) can submit yours. It wasn't likely that this was
the problem though, since that's just an error path that should never
happen (we have <30 genl families, and a 16-bit space for their IDs)

> I realized that kmemleak is not scanning the __ro_after_init
> section...
> Following patch solves the false positives but I wonder if it's the
> right/acceptable solution.

Hah, makes sense to me, but I guess we really want Catalin to comment
:)

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
