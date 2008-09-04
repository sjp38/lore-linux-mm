Date: Thu, 04 Sep 2008 11:51:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH #2.6.27-rc5] mmap: fix petty bug in anonymous shared mmap offset handling
In-Reply-To: <Pine.LNX.4.64.0809031713250.6250@blonde.site>
References: <48BE9AAB.9070303@kernel.org> <Pine.LNX.4.64.0809031713250.6250@blonde.site>
Message-Id: <20080904114324.DB0F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Signed-off-by: Tejun Heo <tj@kernel.org>
> 
> Fair enough.  The current behaviour has (almost) never bothered us,
> so I'm uncertain if your test is legit, but I can't see any reason
> to object to the change.  Particularly since (just out of sight below
> the context of your patch) we force pgoff in the MAP_PRIVATE case.
> 
> Acked-by: Hugh Dickins <hugh@veritas.com>

me too.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
