Date: Wed, 26 Apr 2000 05:45:08 -0700
Message-Id: <200004261245.FAA03090@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000426132915.J3792@redhat.com> (sct@redhat.com)
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <20000426120130.E3792@redhat.com> <Pine.LNX.4.21.0004260814130.16202-100000@duckman.conectiva> <20000426132915.J3792@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: riel@nl.linux.org, sim@stormix.com, jgarzik@mandrakesoft.com, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   If you start treating swap exactly the same, on a page-by-page LRU,
   then a filesystem "find" scan will swap out most of your VM.  Bad
   news.

I never got the impression from the original posting that swap pages
would be treated "exactly" the same, and any sane LRU implementation
which included swap and anonymous pages would prefer clean page
liberation to dirty page liberation.  I consider this a given.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
