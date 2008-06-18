Date: Wed, 18 Jun 2008 10:54:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH][RFC] fix kernel BUG at mm/migrate.c:719! in
 2.6.26-rc5-mm3
Message-Id: <20080618105400.b9f1b664.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080618003129.DE27.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	<20080618003129.DE27.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Jun 2008 00:33:18 +0900, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > @@ -715,13 +725,7 @@ unlock:
> >   		 * restored.
> >   		 */
> >   		list_del(&page->lru);
> > -		if (!page->mapping) {
> > -			VM_BUG_ON(page_count(page) != 1);
> > -			unlock_page(page);
> > -			put_page(page);		/* just free the old page */
> > -			goto end_migration;
> > -		} else
> > -			unlock = putback_lru_page(page);
> > +		unlock = putback_lru_page(page);
> >  	}
> >  
> >  	if (unlock)
> 
> this part is really necessary?
> I tryed to remove it, but any problem doesn't happend.
> 
I made this part first, and added a fix for migration_entry_wait later.

So, I haven't test without this part, and I think it will cause
VM_BUG_ON() here without this part.

Anyway, I will test it.


> Of cource, another part is definitly necessary for specurative pagecache :)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
