Date: Fri, 8 Jun 2001 16:20:24 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.31.0106081313500.3244-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0106081614490.2422-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(adding linux-mm to the discussion for obvious reasons) 

On Fri, 8 Jun 2001, Linus Torvalds wrote:

> 
> 
> On Fri, 8 Jun 2001, Marcelo Tosatti wrote:
> >
> > Don't you think it would be _much_ easier if we just moved _all_ mapped
> > pages to the active list ?
> 
> But they are..
> 
> Sure, there are anonymous pages, but once they get involved in the MM,
> they _will_ be swap-cached, and moved to the active list
> 
> As to putting anonymous pages on the active list, I don't see any
> advantage, 

Again, the advantage which I can see is that we don't have to "wait" until
anonymous pages get swap-cached (and I really dont think all anonymous
pages will get swapcached) to _then_ start to have a fair aging between
all pages in the system. 

> and Davem tried that once with noticeable performance
> degradation from the added locking and list manipulation.

David, 

Could you please send me that code so I can work on it and try to reduce
the performance degradation and take a look at the what it gives us ?

And remember even if we have a performance degradation by the locking and
list manipulation by adding this "feature", it may bring us a big
advantage on the fair aging thing I described above.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
