Date: Thu, 26 Jun 2008 10:31:31 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 10/10] putback_lru_page()/unevictable page handling rework v4
In-Reply-To: <20080625151316.58ed195e.akpm@linux-foundation.org>
References: <20080625191237.D86D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080625151316.58ed195e.akpm@linux-foundation.org>
Message-Id: <20080626103000.FCFC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, riel@redhat.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> And that's kind-of OK.  It's messy, but we could live with it.  However
> as I expect there will be more fixes to these patches before all this
> work goes into mainline, this particular patch will become more of a
> problem as it will make the whole body of work more messy and harder to
> review and understand.
> 
> So.  Can this patch be simplified in any way?  Or split up into
> finer-grained patches or something like that?

Yes, sir!
I'll do it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
