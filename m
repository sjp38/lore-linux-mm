Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C816B6B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 21:08:14 -0400 (EDT)
Received: by vwm42 with SMTP id 42so4021690vwm.14
        for <linux-mm@kvack.org>; Mon, 08 Aug 2011 18:08:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110808212418.GA3297@joi.lan>
References: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
	<20110808212418.GA3297@joi.lan>
Date: Tue, 9 Aug 2011 10:08:12 +0900
Message-ID: <CAC5umyg=zq7BxSrFLtkkpMpKheW7k++KLmQkAfmk56vKn8EykQ@mail.gmail.com>
Subject: Re: [PATCH] slub: fix check_bytes() for slub debugging
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

2011/8/9 Marcin Slusarz <marcin.slusarz@gmail.com>:

> I tested your patch to check if performance improvements of commit
> c4089f98e943ff445665dea49c190657b34ccffe come from this bug or not.
> And forunately they aren't - performance is exactly the same.

That's good to know.

> How did you find it?

When I tried to reuse it in mm/debug-pagealloc.c, I realized that
check_bytes() didn't work with 0xaa.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
