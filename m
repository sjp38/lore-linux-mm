Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 46AA16B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 13:08:52 -0400 (EDT)
Received: by ywh41 with SMTP id 41so3544282ywh.23
        for <linux-mm@kvack.org>; Sun, 16 Aug 2009 10:08:54 -0700 (PDT)
Message-ID: <4A883D21.5020209@gmail.com>
Date: Sun, 16 Aug 2009 11:08:49 -0600
From: Robert Hancock <hancockrwd@gmail.com>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
   slot is freed)
References: <200908122007.43522.ngupta@vflare.org>	 <20090813151312.GA13559@linux.intel.com>	 <20090813162621.GB1915@phenom2.trippelsdorf.de>	 <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>	 <87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>	 <alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>	 <3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>	 <4A85E0DC.9040101@rtr.ca>	 <f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>	 <20090814234539.GE27148@parisc-linux.org>	 <f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>	 <1250341176.4159.2.camel@mulgrave.site>  <4A86B69C.7090001@rtr.ca> <1250344518.4159.4.camel@mulgrave.site> <4A86F2E1.8080002@hp.com>
In-Reply-To: <4A86F2E1.8080002@hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: jim owens <jowens@hp.com>
Cc: James Bottomley <James.Bottomley@suse.de>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/15/2009 11:39 AM, jim owens wrote:
> ***begin rant***
>
> I have not seen any analysis of the benefit and cost to the
> end user of the TRIM or array UNMAP. We now see that TRIM
> as implemented by some (all?) SSDs will come at high cost.
> The cost is all born by the host. Do we get any benefit, or
> is it all for the device vendor. And when we subtract the cost
> from the benefit, does the user actually benefit and how?
>
> I'm tired of working around shit storage products and broken
> device protocols from the "T" committees. I suggest we just
> add a "white list" of devices that handle the discard fast
> and without us needing NCQ queue drain. Then only send TRIM
> to devices that are on the white list and throw the others
> away in the block device layer.

They all will require NCQ queue drain. It's an inherent requirement of 
the protocol that you can't overlap NCQ and non-NCQ commands, and the 
trim command is not NCQ.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
