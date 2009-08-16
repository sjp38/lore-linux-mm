Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C18516B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 18:07:09 -0400 (EDT)
Message-ID: <4A8882E0.5070207@garzik.org>
Date: Sun, 16 Aug 2009 18:06:24 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: Discard support
References: <200908122007.43522.ngupta@vflare.org>	<20090813151312.GA13559@linux.intel.com>	<20090813162621.GB1915@phenom2.trippelsdorf.de>	<alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>	<87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>	<alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>	<3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>	<4A85E0DC.9040101@rtr.ca>	<f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>	<20090814234539.GE27148@parisc-linux.org>	<f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>	<1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca>	<1250344518.4159.4.camel@mulgrave.site>	<20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>	<20090816083434.2ce69859@infradead.org>	<1250437927.3856.119.camel@mulgrave.site> <adavdkn2ztb.fsf@cisco.com>
In-Reply-To: <adavdkn2ztb.fsf@cisco.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Roland Dreier <rdreier@cisco.com>
Cc: James Bottomley <James.Bottomley@suse.de>, Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 08/16/2009 05:50 PM, Roland Dreier wrote:
>
>   >  Well, yes and no ... a lot of SSDs don't actually implement NCQ, so the
>   >  impact to them will be less ... although I think enterprise class SSDs
>   >  do implement NCQ.
>
> Really?  Which SSDs don't implement NCQ?

ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata3.00: ATA-8: G.SKILL 128GB SSD, 02.10104, max UDMA/100
ata3.00: 250445824 sectors, multi 0: LBA
ata3.00: configured for UDMA/100

for one...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
