Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 09109900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 11:38:01 -0400 (EDT)
Message-ID: <4E035DD1.1030603@kpanic.de>
Date: Thu, 23 Jun 2011 17:37:53 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org> <4E0348E0.7050808@kpanic.de> <20110623141222.GA30003@srcf.ucam.org>
In-Reply-To: <20110623141222.GA30003@srcf.ucam.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net

On 23.06.2011 16:12, Matthew Garrett wrote:
> On Thu, Jun 23, 2011 at 04:08:32PM +0200, Stefan Assmann wrote:
>> On 23.06.2011 15:39, Matthew Garrett wrote:
>>> Would it be more reasonable to do this in the bootloader? You'd ideally 
>>> want this to be done as early as possible in order to avoid awkward 
>>> situations like your ramdisk ending up in the bad RAM area.
>>
>> Not sure what exactly you are suggesting here. The kernel somehow needs
>> to know what memory areas to avoid so we supply this information via
>> kernel command line.
>> What the bootloader could do is to allow the kernel/initrd to be loaded
>> at an alternative address. That's briefly mentioned in the BadRAM
>> Documentation as well. Is that what you mean or am I missing something?
> 
> For EFI booting we just hand an e820 map to the kernel. It ought to be 
> easy enough to add support for that to the 16-bit entry point as well. 
> Then the bootloader just needs to construct an e820 map of its own. I 
> think grub2 actually already has some support for this. The advantage of 
> this approach is that the knowledge of bad memory only has to exist in 
> one place (ie, the bootloader) - the kernel can remain blisfully 
> unaware.
> 

According to Rick's reply in this thread a damaged row in a DIMM can
easily cause a few thousand entries in the e820 table because it doesn't
handle patterns. So the question I'm asking is, is it acceptable to
have an e820 table with thousands maybe ten-thousands of entries?
I really have no idea of the implications, maybe somebody else can
comment on that.

  Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
