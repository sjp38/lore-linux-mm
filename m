Subject: Re: Swapping for diskless nodes
Message-ID: <OF452D802E.BE93E657-ON85256AA3.004E8422@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Thu, 9 Aug 2001 10:26:22 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Dirk W. Steinberg" <dws@dirksteinberg.de>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>



>In such a scenario I would disagree with Alan that network paging is
>high latency as compared to disk access. I have a fully switched 100 Mpbs
>full-duplex ethernet network, and sending a page across the net into
>the memory of a fast server could have much less latency that writing
>that page out to a local old, slow IDE disk.

Have you actually tried swapping over the network using nbd or any other
network device mounted as a swap disk?  Never mind the latency.  Does it
work at all?  I am curious to know.

Last time I checked swapping over nbd required patching the network stack.
Because swapping occurs when memory is low and when memory is low TCP
doesn't do what you expect it to do...
Bulent



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
