In-reply-to: <20070406040035.2f1e1105.akpm@linux-foundation.org> (message from
	Andrew Morton on Fri, 6 Apr 2007 04:00:35 -0700)
Subject: Re: [PATCH 12/12] mm: per BDI congestion feedback
References: <20070405174209.498059336@programming.kicks-ass.net>
	<20070405174320.649550491@programming.kicks-ass.net>
	<20070405162425.eb78c701.akpm@linux-foundation.org>
	<1175842917.6483.130.camel@twins> <20070406040035.2f1e1105.akpm@linux-foundation.org>
Message-Id: <E1HZmLH-000319-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 06 Apr 2007 13:10:55 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

> > OK, so you disagree with Miklos' 2nd point here:
> >   http://lkml.org/lkml/2007/4/4/137
> 
> Yup, silly man thought that "congestion_wait" has something to do with
> congestion ;)  I think it sort-of used to, once.

Oh well.  I _usually_ do actually read the code, but this seemed so
obvious...  I'll learn never to trust descriptive function names.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
