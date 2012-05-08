Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E1E946B0044
	for <linux-mm@kvack.org>; Tue,  8 May 2012 15:11:21 -0400 (EDT)
Received: by eekb47 with SMTP id b47so2007029eek.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 12:11:20 -0700 (PDT)
Subject: Re: [PATCH] mm: sl[auo]b: Use atomic bit operations to update
 page-flags.
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1336503339-18722-1-git-send-email-pshelar@nicira.com>
References: <1336503339-18722-1-git-send-email-pshelar@nicira.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 May 2012 21:11:16 +0200
Message-ID: <1336504276.3752.2600.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin B Shelar <pshelar@nicira.com>
Cc: cl@linux.com, penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Tue, 2012-05-08 at 11:55 -0700, Pravin B Shelar wrote:
> Transparent huge pages can change page->flags (PG_compound_lock)
> without taking Slab lock. So sl[auo]b need to use atomic bit
> operation while changing page->flags.
> Specificly this patch fixes race between compound_unlock and slab
> functions which does page-flags update. This can occur when
> get_page/put_page is called on page from slab object.


But should get_page()/put_page() be called on a page own by slub ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
