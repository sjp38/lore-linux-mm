Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 237168D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 12:54:11 -0400 (EDT)
Message-ID: <4DB5A71A.5080802@genband.com>
Date: Mon, 25 Apr 2011 10:53:46 -0600
From: Chris Friesen <chris.friesen@genband.com>
MIME-Version: 1.0
Subject: Re: Background memory scrubbing
References: <18563.1303314382@jupiter.eclipse.co.uk> <20110420160125.GC2312@gere.osrc.amd.com>
In-Reply-To: <20110420160125.GC2312@gere.osrc.amd.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@amd64.org>
Cc: Robert Whitton <rwhitton@iee.org>, Clemens Ladisch <clemens@ladisch.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/20/2011 10:01 AM, Borislav Petkov wrote:
> On Wed, Apr 20, 2011 at 04:46:22PM +0100, Robert Whitton wrote:
>>
>>> On Wed, Apr 20, 2011 at 05:19:41PM +0200, Clemens Ladisch wrote:
>>>>> Unfortunately in common with a large number of hardware platforms
>>>>> background scrubbing isn't supported in the hardware (even though ECC
>>>>> error correction is supported) and thus there is no BIOS option to
>>>>> enable it.
>>>>
>>>> Which hardware platform is this? AFAICT all architectures with ECC
>>>> (old AMD64, Family 0Fh, Family 10h) also have scrubbing support.
>>>> If your BIOS is too dumb, just try enabling it directly (bits 0-4 of
>>>> PCI configuration register 0x58 in function 3 of the CPU's northbridge
>>>> device, see the BIOS and Kernel's Developer's Guide for details).
>>>
>>> Or even better, if on AMD, you can build the amd64_edac module
>>> (CONFIG_EDAC_AMD64) and do
>>>
>>> echo  > /sys/devices/system/edac/mc/mc/sdram_scrub_rate
>>>
>>> where x is the scrubbing bandwidth in bytes/sec and y is the memory
>>> controller on the machine, i.e. node.
>>
>> Unfortunately that also isn't an option on my platform(s). There surely must be a way for a module to be able to get a mapping for each physical page of memory in the system and to be able to use that mapping to do atomic read/writes to scrub the memory.
> 
> For such questions I've added just the right ML to Cc :).

There was a thread back in 2009 cwith the subject "marching through all
physical memory in software" that discussed some of the issues of a
software background scrub.

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
