Message-ID: <XFMail.20030124180942.pochini@shiny.it>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
In-Reply-To: <3E316421.5070905@cyberone.com.au>
Date: Fri, 24 Jan 2003 18:09:42 +0100 (CET)
From: Giuliano Pochini <pochini@shiny.it>
Subject: Re: 2.5.59-mm5
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-kernel@alex.org.uk, Alex Tomas <bzzz@tmi.comex.ru>, Andrew Morton <akpm@digeo.com>, Oliver Xymoron <oxymoron@waste.org>
List-ID: <linux-mm.kvack.org>

>>An alternate approach might be to change the way the scheduler splits
>>things. That is, rather than marking I/O read vs write and scheduling
>>based on that, add a flag bit to mark them all sync vs async since
>>that's the distinction we actually care about. The normal paths can
>>all do read+sync and write+async, but you can now do things like
>>marking your truncate writes sync and readahead async.

> That will be worth investigating to see if the complexity is worth it.
> I think from a disk point of view, we still want to split batches between
> reads and writes. Could be wrong.

Yes, sync vs async is a better way to classify io requests than
read vs write and it's more correct from OS point of view. IMHO
it's not more complex then now. Just replace r/w with sy/as and
it will work.


Bye.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
