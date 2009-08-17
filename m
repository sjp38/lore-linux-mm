Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 653A96B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 22:05:42 -0400 (EDT)
Message-ID: <4A88BAF5.2000009@rtr.ca>
Date: Sun, 16 Aug 2009 22:05:41 -0400
From: Mark Lord <liml@rtr.ca>
MIME-Version: 1.0
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
References: <200908122007.43522.ngupta@vflare.org>	<20090813151312.GA13559@linux.intel.com>	<20090813162621.GB1915@phenom2.trippelsdorf.de>	<alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>	<87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>	<alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>	<3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>	<4A85E0DC.9040101@rtr.ca>	<f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>	<20090814234539.GE27148@parisc-linux.org>	<f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>	<1250341176.4159.2.camel@mulgrave.site>	<4A86B69C.7090001@rtr.ca>	<1250344518.4159.4.camel@mulgrave.site>	<20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>	<20090816083434.2ce69859@infradead.org> <20090816202905.59efa611@lxorguk.ukuu.org.uk> <4A8890B8.6070409@anonymous.org.uk>
In-Reply-To: <4A8890B8.6070409@anonymous.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: John Robinson <john.robinson@anonymous.org.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Arjan van de Ven <arjan@infradead.org>, James Bottomley <James.Bottomley@suse.de>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

John Robinson wrote:
..
> I'm slightly out of my depth here, but: if a single TRIM is issued, 
> which apparently returns quickly, can one then revert to issuing 
> ordinary commands like reads and writes and have them complete as 
> quickly as they normally do, or does any following command have to wait 
> until the trim completes? This could be useful if it turned out we won't 
> stall these devices as long as we don't issue more than one TRIM every 
> few seconds; we could keep a TRIM coalesce queue down to being (say) 5 
> seconds long (or at least, a configurable small number of seconds).
..

I have not attempted to instrument that, but I suspect that any
command after the TRIM has to wait.  Don't know for sure until
somebody measures it though.

One thing I do know, is that Matthew's first cut of TRIM support
means it takes half an hour to do "rm -r" on a kernel source tree.

-ml

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
