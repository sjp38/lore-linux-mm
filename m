Received: from luxury.wat.veritas.com([10.10.192.121]) (1431 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m156tJw-0001raC@megami.veritas.com>
	for <linux-mm@kvack.org>; Mon, 4 Jun 2001 05:18:56 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Mon, 4 Jun 2001 13:20:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
In-Reply-To: <20010603190450.A26234@home.ds9a.nl>
Message-ID: <Pine.LNX.4.21.0106041306560.9228-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bert hubert <ahu@ds9a.nl>
Cc: linux-mm@kvack.org, aeb@cwi.nl
List-ID: <linux-mm.kvack.org>

On Sun, 3 Jun 2001, bert hubert wrote:
> 
> As promised, a manpage. I alreasy sent it to Andries but the people over
> here may also have comments.

I think cut out the reference to PAGE_CACHE_SIZE.  mincore()'s current
kernel implementation may indeed involve PAGE_CACHE_SIZE, but I believe
that if PAGE_CACHE_SIZE is ever changed away from PAGE_SIZE, that will
be a kernel implementation detail, which should not affect its interfaces
with user-space.  You're right to SEE ALSO getpagesize: really even the
references to PAGE_SIZE should defer to getpagesize e.g. the mmap man
page (on my RH7 anyway) says "offset should ordinarily be a multiple of
the page size returned by getpagesize(2)"; but it may get tiresome to use
that circumlocution ("the artist formerly known as Prince") everywhere.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
