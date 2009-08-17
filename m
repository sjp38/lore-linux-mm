Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 768676B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 16:19:36 -0400 (EDT)
Message-ID: <4A89BB5B.5060403@rtr.ca>
Date: Mon, 17 Aug 2009 16:19:39 -0400
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
  slot is freed)
References: <200908122007.43522.ngupta@vflare.org>	 <20090816083434.2ce69859@infradead.org>	 <1250437927.3856.119.camel@mulgrave.site> <4A8834B6.2070104@rtr.ca>	 <1250446047.3856.273.camel@mulgrave.site> <4A884D9C.3060603@rtr.ca>	 <1250447052.3856.294.camel@mulgrave.site> <4A898752.9000205@tmr.com>	 <87f94c370908171008t44ff64ack2153e740128278e@mail.gmail.com>	 <1250529575.7858.31.camel@mulgrave.site>	 <87f94c370908171121u5ee8016p253824b16851b48@mail.gmail.com> <1250536709.7858.43.camel@mulgrave.site>
In-Reply-To: <1250536709.7858.43.camel@mulgrave.site>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Bill Davidsen <davidsen@tmr.com>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

James Bottomley wrote:
> On Mon, 2009-08-17 at 14:21 -0400, Greg Freemyer wrote:
>> On Mon, Aug 17, 2009 at 1:19 PM, James Bottomley<James.Bottomley@suse.de> wrote:
>>> On Mon, 2009-08-17 at 13:08 -0400, Greg Freemyer wrote:
..
>>>> Non-coalescing is believed detrimental,
>>> It is?  Why?
>> For the only compliant SSD in the wild, Mark has shown it to be true
>> via testing.
> 
> He only said larger trims take longer.  As I said previously, if it's a
> X+nY relationship, then we still benefit from accumulation up to some
> value of n.
..

Err, what I said was, "rm -rf /usr/src/linux" takes over half an hour
with uncoalesced TRIM, and only a scant few seconds in total *with*
coalesced TRIM.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
