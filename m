Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C23C46B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 12:45:33 -0500 (EST)
Date: Fri, 19 Dec 2008 19:00:09 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
Message-ID: <20081219180009.GP25779@one.firstfloor.org>
References: <4941590F.3070705@vlnb.net> <1229022734.3266.67.camel@localhost.localdomain> <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net> <87zlisz9pg.fsf@basil.nowhere.org> <494BDBFC.7060707@vlnb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <494BDBFC.7060707@vlnb.net>
Sender: owner-linux-mm@kvack.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Sure, this is why I propose to disable that option by default in 
> distribution kernels, so it would produce no harm.

That would make the option useless for most users. You might as well
not bother merging then.

> first, only then enable that option, then rebuild the kernel. (I'm 
> repeating it to make sure you didn't miss this my point; it was in the 
> part of my original message, which you cut out.)

That was such a ridiculous suggestion, I didn't take it seriously.

Also it should be really not rocket science to use a separate 
table for this.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
