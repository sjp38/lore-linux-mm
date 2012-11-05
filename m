Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 705106B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 16:44:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4634017pad.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 13:44:34 -0800 (PST)
Date: Mon, 5 Nov 2012 13:44:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: bugfix: set current->reclaim_state to NULL while
 returning from kswapd()
In-Reply-To: <CAEtiSasbEXUeFwCNO09nT8TsEzLF-zZVyJ_pCO9V49hDPbpbAQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211051342240.5296@chino.kir.corp.google.com>
References: <CAEtiSasbEXUeFwCNO09nT8TsEzLF-zZVyJ_pCO9V49hDPbpbAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Minchan Kim <minchan.kim@gmail.com>, takamori.yamaguchi@jp.sony.com, takuzo.ohara@ap.sony.com, amit.agarwal@ap.sony.com, tim.bird@am.sony.com, frank.rowand@am.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Tue, 6 Nov 2012, Aaditya Kumar wrote:

> From: Takamori Yamaguchi <takamori.yamaguchi@jp.sony.com>
> 
> In kswapd(), set current->reclaim_state to NULL before returning, as
> current->reclaim_state holds reference to variable on kswapd()'s stack.
> 
> In rare cases, while returning from kswapd() during memory off lining,
> __free_slab() can access dangling pointer of current->reclaim_state.
> 

It's __free_slab() for slub and kmem_freepages() for slab.

> Signed-off-by: Takamori Yamaguchi <takamori.yamaguchi@jp.sony.com>
> Signed-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
