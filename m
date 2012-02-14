Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 9F5A96B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 03:10:39 -0500 (EST)
Received: by lamf4 with SMTP id f4so6325224lam.14
        for <linux-mm@kvack.org>; Tue, 14 Feb 2012 00:10:37 -0800 (PST)
Date: Tue, 14 Feb 2012 10:10:30 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
In-Reply-To: <CAO_0yfPtibyYKZWtf0y3nFaijcuEKZbejaWsOFebrEinv_O0_Q@mail.gmail.com>
Message-ID: <alpine.LFD.2.02.1202141009130.3795@tux.localdomain>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com> <alpine.LFD.2.02.1202140929040.2721@tux.localdomain> <CAO_0yfPtibyYKZWtf0y3nFaijcuEKZbejaWsOFebrEinv_O0_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Bai <hamo.by@gmail.com>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, 14 Feb 2012, Yang Bai wrote:
> I did not find anything like SLAB_OVERFLOW using grep. Could you
> explain it more in detail?

You should add a new config option to lib/Kconfig.debug and wrap the debug 
check with it.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
