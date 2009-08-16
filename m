Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 160A06B004D
	for <linux-mm@kvack.org>; Sun, 16 Aug 2009 17:50:37 -0400 (EDT)
From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Discard support
References: <200908122007.43522.ngupta@vflare.org>
	<20090813151312.GA13559@linux.intel.com>
	<20090813162621.GB1915@phenom2.trippelsdorf.de>
	<alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
	<87f94c370908131115r680a7523w3cdbc78b9e82373c@mail.gmail.com>
	<alpine.DEB.1.10.0908131342460.28013@asgard.lang.hm>
	<3e8340490908131354q167840fcv124ec56c92bbb830@mail.gmail.com>
	<4A85E0DC.9040101@rtr.ca>
	<f3177b9e0908141621j15ea96c0s26124d03fc2b0acf@mail.gmail.com>
	<20090814234539.GE27148@parisc-linux.org>
	<f3177b9e0908141719s658dc79eye92ab46558a97260@mail.gmail.com>
	<1250341176.4159.2.camel@mulgrave.site> <4A86B69C.7090001@rtr.ca>
	<1250344518.4159.4.camel@mulgrave.site>
	<20090816150530.2bae6d1f@lxorguk.ukuu.org.uk>
	<20090816083434.2ce69859@infradead.org>
	<1250437927.3856.119.camel@mulgrave.site>
Date: Sun, 16 Aug 2009 14:50:40 -0700
In-Reply-To: <1250437927.3856.119.camel@mulgrave.site> (James Bottomley's
	message of "Sun, 16 Aug 2009 10:52:07 -0500")
Message-ID: <adavdkn2ztb.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@suse.de>
Cc: Arjan van de Ven <arjan@infradead.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Mark Lord <liml@rtr.ca>, Chris Worley <worleys@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Bryan Donlan <bdonlan@gmail.com>, david@lang.hm, Greg Freemyer <greg.freemyer@gmail.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, Linux RAID <linux-raid@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


 > Well, yes and no ... a lot of SSDs don't actually implement NCQ, so the
 > impact to them will be less ... although I think enterprise class SSDs
 > do implement NCQ.

Really?  Which SSDs don't implement NCQ?

It seems that one couldn't keep the flash busy doing only one command at time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
