Date: Fri, 3 Nov 2000 06:51:05 -0800
Message-Id: <200011031451.GAA10924@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <200011031456.JAA21492@tsx-prime.MIT.EDU> (tytso@MIT.EDU)
Subject: Re: BUG FIX?: mm->rss is modified in some places without holding the  page_table_lock
References: <200011031456.JAA21492@tsx-prime.MIT.EDU>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tytso@MIT.EDU
Cc: davej@suse.de, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   Are you saying that the original bug report may not actually be a
   problem?  Is ms->rss actually protected in _all_ of the right
   places, but people got confused because of the syntactic sugar?

I don't know if all of them are ok, most are.

Someone would need to do the analysis.  David's patch could be used as
a good starting point.  A quick glance at mm/memory.c shows these
spots need to be fixed:

1) End of zap_page_range()
2) Middle of do_swap_page
3) do_anonymous_page
4) do_no_page

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
