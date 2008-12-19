Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5736B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 06:24:35 -0500 (EST)
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
From: Andi Kleen <andi@firstfloor.org>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net>
	<20081210214500.GA24212@ioremap.net> <4941590F.3070705@vlnb.net>
	<1229022734.3266.67.camel@localhost.localdomain>
	<4942BAB8.4050007@vlnb.net>
	<1229110673.3262.94.camel@localhost.localdomain>
	<49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org>
	<4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net>
Date: Fri, 19 Dec 2008 12:27:23 +0100
In-Reply-To: <494A97DD.7080503@vlnb.net> (Vladislav Bolkhovitin's message of "Thu, 18 Dec 2008 21:35:09 +0300")
Message-ID: <87zlisz9pg.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Vladislav Bolkhovitin <vst@vlnb.net> writes:
>
>  - Although usage of struct page to keep network related pointer might
> look as a layering violation, it isn't. I wrote in
> http://lkml.org/lkml/2008/12/15/190 why.

Sorry but extending struct page for this is really a bad idea because
of the extreme memory overhead even when it's not used (which is a 
problem on distribution kernels) Find some other way to store this
information.  Even for patches with more general value it was not
acceptable.

-Andi


-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
