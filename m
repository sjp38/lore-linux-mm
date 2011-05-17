Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 330D390010B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 00:53:03 -0400 (EDT)
Received: by wwi36 with SMTP id 36so104968wwi.26
        for <linux-mm@kvack.org>; Mon, 16 May 2011 21:52:59 -0700 (PDT)
Subject: Re: [slubllv5 03/25] slub: Make CONFIG_PAGE_ALLOC work with new
 fastpath
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <20110516202622.862544137@linux.com>
References: <20110516202605.274023469@linux.com>
	 <20110516202622.862544137@linux.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 May 2011 06:52:54 +0200
Message-ID: <1305607974.9466.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Le lundi 16 mai 2011 A  15:26 -0500, Christoph Lameter a A(C)crit :
> piA?ce jointe document texte brut (fixup)
> Fastpath can do a speculative access to a page that CONFIG_PAGE_ALLOC may have

CONFIG_DEBUG_PAGE_ALLOC

> marked as invalid to retrieve the pointer to the next free object.
> 
> Use probe_kernel_read in that case in order not to cause a page fault.
> 

Some credits would be good, it would certainly help both of us.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>

> Signed-off-by: Christoph Lameter <cl@linux.com>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>


> ---
>  mm/slub.c |   14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
