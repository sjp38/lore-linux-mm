Date: Tue, 15 Jun 2004 23:40:02 +0200 (CEST)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
In-Reply-To: <Pine.LNX.4.44L0.0406151221220.1960-100000@ida.rowland.org>
Message-ID: <Pine.LNX.4.60.0406152239420.4330@poirot.grange>
References: <Pine.LNX.4.44L0.0406151221220.1960-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: David Brownell <david-b@pacbell.net>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, USB development list <linux-usb-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2004, Alan Stern wrote:

> On Mon, 14 Jun 2004, David Brownell wrote:
>
>> Seems like the dma_alloc_coherent() API spec can't be
>> implemented on such machines then, since it's defined
>> to return memory(*) such that:
>>
>>    ... a write by either the device or the processor
>>    can immediately be read by the processor or device
>>    without having to worry about caching effects.
>>
>> Seems like the documentation should change to explain
>> under what circumstances "coherent" memory will exhibit
>> cache-incoherent behavior, and how to cope with that.
>> (Then lots of drivers would need to change.)
>>
>> OR ... maybe the bug is just that those PPC processors
>> can't/shouldn't claim to implement that API.  At which
>> point all drivers relying on that API (including all
>> the USB HCDs and many of the USB drivers) stop working.
>>
>> - Dave
>>
>> (*) DMA-API.txt uses two terms for this:  "coherent" and "consistent".
>>      DMA-mapping.txt only uses "consistent".
>
> That text strikes me as rather ambiguous.  Maybe it's intended to mean
> that a write by either side can be read immediately by the other side, and
> the values read will be the ones written (i.e., the read won't get stale
> data from some cache).  It doesn't specify what happens to the other data
> bytes in the same cache line which _weren't_ written -- maybe they'll be
> messed up.
>
> In other words, with "coherent" or "consistent" memory (there is some
> technical distinction between the two terms but I don't know what it is)

<quote>
