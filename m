Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5E68E900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 10:08:42 -0400 (EDT)
Message-ID: <4E0348E0.7050808@kpanic.de>
Date: Thu, 23 Jun 2011 16:08:32 +0200
From: Stefan Assmann <sassmann@kpanic.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110623133950.GB28333@srcf.ucam.org>
In-Reply-To: <20110623133950.GB28333@srcf.ucam.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net

On 23.06.2011 15:39, Matthew Garrett wrote:
> On Wed, Jun 22, 2011 at 01:18:51PM +0200, Stefan Assmann wrote:
>> Following the RFC for the BadRAM feature here's the updated version with
>> spelling fixes, thanks go to Randy Dunlap. Also the code is now less verbose,
>> as requested by Andi Kleen.
>> v2 with even more spelling fixes suggested by Randy.
>> Patches are against vanilla 2.6.39.
>> Repost with LKML in Cc as suggested by Andrew Morton.
> 
> Would it be more reasonable to do this in the bootloader? You'd ideally 
> want this to be done as early as possible in order to avoid awkward 
> situations like your ramdisk ending up in the bad RAM area.

Not sure what exactly you are suggesting here. The kernel somehow needs
to know what memory areas to avoid so we supply this information via
kernel command line.
What the bootloader could do is to allow the kernel/initrd to be loaded
at an alternative address. That's briefly mentioned in the BadRAM
Documentation as well. Is that what you mean or am I missing something?

  Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
