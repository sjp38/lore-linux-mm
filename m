Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 589A66B0047
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 13:41:39 -0500 (EST)
Message-ID: <494A99EF.6070400@flurg.com>
Date: Thu, 18 Dec 2008 12:43:59 -0600
From: "David M. Lloyd" <dmlloyd@flurg.com>
MIME-Version: 1.0
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <20081210214500.GA24212@ioremap.net> <4941590F.3070705@vlnb.net> <1229022734.3266.67.camel@localhost.localdomain> <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net>
In-Reply-To: <494A97DD.7080503@vlnb.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vladislav Bolkhovitin <vst@vlnb.net>
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 12/18/2008 12:35 PM, Vladislav Bolkhovitin wrote:
> An iSCSI target driver iSCSI-SCST was a part of the patchset 
> (http://lkml.org/lkml/2008/12/10/293). For it a nice optimization to 
> have TCP zero-copy transmit of user space data was implemented. Patch, 
> implementing this optimization was also sent in the patchset, see 
> http://lkml.org/lkml/2008/12/10/296.

I'm probably ignorant of about 90% of the context here, but isn't this the 
sort of problem that was supposed to have been solved by vmsplice(2)?

- DML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
