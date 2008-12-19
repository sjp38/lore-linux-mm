Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0CEF26B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 12:34:50 -0500 (EST)
Message-ID: <494BDBC5.7050701@vlnb.net>
Date: Fri, 19 Dec 2008 20:37:09 +0300
From: Vladislav Bolkhovitin <vst@vlnb.net>
MIME-Version: 1.0
Subject: Re: [RFC]: Support for zero-copy TCP transmit of user space data
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <20081210214500.GA24212@ioremap.net> <4941590F.3070705@vlnb.net> <1229022734.3266.67.camel@localhost.localdomain> <4942BAB8.4050007@vlnb.net> <1229110673.3262.94.camel@localhost.localdomain> <49469ADB.6010709@vlnb.net> <20081215231801.GA27168@infradead.org> <4947FA1C.2090509@vlnb.net> <494A97DD.7080503@vlnb.net> <494A99EF.6070400@flurg.com>
In-Reply-To: <494A99EF.6070400@flurg.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "David M. Lloyd" <dmlloyd@flurg.com>
Cc: linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net, Bart Van Assche <bart.vanassche@gmail.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David M. Lloyd, on 12/18/2008 09:43 PM wrote:
> On 12/18/2008 12:35 PM, Vladislav Bolkhovitin wrote:
>> An iSCSI target driver iSCSI-SCST was a part of the patchset 
>> (http://lkml.org/lkml/2008/12/10/293). For it a nice optimization to 
>> have TCP zero-copy transmit of user space data was implemented. Patch, 
>> implementing this optimization was also sent in the patchset, see 
>> http://lkml.org/lkml/2008/12/10/296.
> 
> I'm probably ignorant of about 90% of the context here, but isn't this the 
> sort of problem that was supposed to have been solved by vmsplice(2)?

No, vmsplice can't help here. ISCSI-SCST is a kernel space driver. But, 
even if it was a user space driver, vmsplice wouldn't change anything 
much. It doesn't have a possibility for a user to know, when 
transmission of the data finished. So, it is intended to be used as: 
vmsplice() buffer -> munmap() the buffer -> mmap() new buffer -> 
vmsplice() it. But on the mmap() stage kernel has to zero all the newly 
mapped pages and zeroing memory isn't much faster, than copying it. 
Hence, there would be no considerable performance increase.

Thanks,
Vlad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
