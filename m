Date: Wed, 18 Jun 2008 19:20:20 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [Bad page] trying to free locked page? (Re: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3)
In-Reply-To: <20080618113235.c89ec08d.nishimura@mxp.nes.nec.co.jp>
References: <20080618003334.DE2A.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080618113235.c89ec08d.nishimura@mxp.nes.nec.co.jp>
Message-Id: <20080618191814.37BC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > I got bad_page after hundreds times of page migration.
> > > It seems that a locked page is being freed.
> > 
> > I can't reproduce this bad page.
> > I'll try again tomorrow ;)
> 
> OK. I'll report on my test more precisely.

Thank you verbose explain.
I ran its testcase >3H today.
but unfortunately, I couldn't reproduce it.

Hmm...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
