Message-ID: <3B50A7ED.7A8A1BF0@rentec.com>
Date: Sat, 14 Jul 2001 16:13:33 -0400
From: Dirk <dirkw@rentec.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
References: <Pine.LNX.4.21.0107140204110.4153-100000@freak.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@conectiva.com.br>, Mike Galbraith <mikeg@wen-online.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> Hi,
>
> As well known, the VM does not make a distiction between global and
> per-zone shortages when trying to free memory. That means if only a given
> memory zone is under shortage, the kernel will scan pages from all zones.
>
> The following patch (against 2.4.6-ac2), changes the kernel behaviour to
> avoid freeing pages from zones which do not have an inactive and/or
> free shortage.
>
> Now I'm able to run memory hogs allocating 4GB of memory (on 4GB machine)
> without getting real long hangs on my ssh session. (which used to happen
> on stock -ac2 due to exhaustion of DMA pages for networking).
>
> Comments ?
>
> Dirk, Can you please try the patch and tell us if it fixes your problem ?
>

great!! that is definitely better, the machine talks to me again. there are some
small "but"s. however. i write them up and let you know.

    ~dirkw


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
