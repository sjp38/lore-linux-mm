Subject: Re: PG_slab?
References: <20040920200953.GF5521@logos.cnet>
	<20040920153154.61e0b413.pj@sgi.com>
From: Sean Neakums <sneakums@zork.net>
Date: Tue, 21 Sep 2004 16:36:50 +0100
In-Reply-To: <20040920153154.61e0b413.pj@sgi.com> (Paul Jackson's message of
	"Mon, 20 Sep 2004 15:31:54 -0700")
Message-ID: <6uy8j363cd.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson <pj@sgi.com> writes:

> Marcelo writes:
>> What is PG_slab about?
>
> A grep in a 2.6.0-mm1 I have expanded shows that its some slab debug
> stuff that Suparna wanted.  The last grep at the bottom of this display
> is in the routine mm/slab.c: ptrinfo(), that dumps data about some
> address.

I guess this patch or something like it was merged:

Date: Wed, 1 Sep 2004 12:02:23 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove ptrinfo

http://lkml.org/lkml/2004/9/1/70
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
