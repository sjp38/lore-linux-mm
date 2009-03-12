Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C18E66B0055
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 08:19:21 -0400 (EDT)
From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may  get wrongly discarded
Date: Thu, 12 Mar 2009 08:19:08 -0400
References: <20090311170207.1795cad9.akpm@linux-foundation.org> <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com> <20090312100049.43A3.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-ID: <200903120819.08724.rgetz@blackfin.uclinux.org>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed 11 Mar 2009 21:04, KOSAKI Motohiro pondered:
> Hi
> 
> > >> Page reclaim shouldn't be even attempting to reclaim or write back
> > >> ramfs pagecache pages - reclaim can't possibly do anything with 
> > >> these pages!
> > >>
> > >> Arguably those pages shouldn't be on the LRU at all, but we haven't
> > >> done that yet.
> > >>
> > >> Now, my problem is that I can't 100% be sure that we _ever_
> > >> implemented this properly. ?I _think_ we did, in which case 
> > >> we later broke it. ?If we've always been (stupidly) trying 
> > >> to pageout these pages then OK, I guess your patch is a 
> > >> suitable 2.6.29 stopgap. 
> > >
> > > OK, I can't find any code anywhere in which we excluded ramfs pages
> > > from consideration by page reclaim. ?How dumb.
> > 
> > The ramfs  considers it in just CONFIG_UNEVICTABLE_LRU case
> > It that case, ramfs_get_inode calls mapping_set_unevictable.
> > So,  page reclaim can exclude ramfs pages by page_evictable.
> > It's problem .
> 
> Currently, CONFIG_UNEVICTABLE_LRU can't use on nommu machine
> because nobody of vmscan folk havbe nommu machine.
> 
> Yes, it is very stupid reason. _very_ welcome to tester! :)

As always - if you (or any kernel developer) would like a noMMU machine to 
test on - please send me a private email.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
