Date: Wed, 25 Jun 2008 15:13:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 10/10] putback_lru_page()/unevictable page handling
 rework v4
Message-Id: <20080625151316.58ed195e.akpm@linux-foundation.org>
In-Reply-To: <20080625191237.D86D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080625191014.D86A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080625191237.D86D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, riel@redhat.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jun 2008 19:14:54 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> putback_lru_page()/unevictable page handling rework.

The other nine patches slotted into the patch series quite nicely. 
This means that those nine patches can later be folded into the patches
which they fixed and everything is nice and logical.

But this patch is not like that - it changes code which was added by
lots of different patches.  This means that if I merge it, this patch
besomes a sort of impermeable barrier which other patches cannot be
reordered across.

And that's kind-of OK.  It's messy, but we could live with it.  However
as I expect there will be more fixes to these patches before all this
work goes into mainline, this particular patch will become more of a
problem as it will make the whole body of work more messy and harder to
review and understand.

So.  Can this patch be simplified in any way?  Or split up into
finer-grained patches or something like that?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
