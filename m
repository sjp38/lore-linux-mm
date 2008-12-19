Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 283926B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 12:55:33 -0500 (EST)
Message-ID: <494BE08D.30101@vlnb.net>
Date: Fri, 19 Dec 2008 20:57:33 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
MIME-Version: 1.0
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
References: <4941590F.3070705@vlnb.net> <1229022734.3266.67.camel@localhost.localdomain> <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net> <87zlisz9pg.fsf@basil.nowhere.org> <494BDBFC.7060707@vlnb.net> <20081219180009.GP25779@one.firstfloor.org>
In-Reply-To: <20081219180009.GP25779@one.firstfloor.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen, on 12/19/2008 09:00 PM wrote:
>> Sure, this is why I propose to disable that option by default in 
>> distribution kernels, so it would produce no harm.
> 
> That would make the option useless for most users. You might as well
> not bother merging then.

I believe 99.(9)% of users prefer don't patch kernel, if possible.

>> first, only then enable that option, then rebuild the kernel. (I'm 
>> repeating it to make sure you didn't miss this my point; it was in the 
>> part of my original message, which you cut out.)
> 
> That was such a ridiculous suggestion, I didn't take it seriously.
> 
> Also it should be really not rocket science to use a separate 
> table for this.

Sorry, what do you mean? If usage of something like a hash table to map 
pages to the corresponding iSCSI commands, this approach was evaluated 
and rejected, because it wouldn't provide much performance increase, 
which would worth the effort. See details in the end of the patch 
description in http://lkml.org/lkml/2008/12/10/296

Thanks,
Vlad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
