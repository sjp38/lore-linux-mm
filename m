Subject: Re: [PATCH] Remove nr_async_pages limit
References: <E156o18-00059a-00@the-village.bc.nu>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 04 Jun 2001 10:21:32 +0200
In-Reply-To: <E156o18-00059a-00@the-village.bc.nu> (Alan Cox's message of "Mon, 4 Jun 2001 07:39:10 +0100 (BST)")
Message-ID: <87iticfyer.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> > This patch removes the limit on the number of async pages in the
> > flight.
> 
> I have this in all  2.4.5-ac. It does help a little but there are some other
> bits you have to deal with too, in paticular wrong aging. See the -ac version
> 

Yes, I'll check -ac to see your changes. Although, I can't see what is
the impact of the unlimited number of the async pages on the aging, I
don't see a connection?!

In the mean time I tested the patch even more thoroughly under various
loads and I can't find any problem with it. Performance is same or
better a little bit, as you say. :)

My other patch (enlarging inactive dirty list) has a much bigger
impact on the aging process, but I also see only improvement with
it. I think that swap_out path should be tweaked a little bit (it is
too aggressive now), and then things will come up even better.

Regards,
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
