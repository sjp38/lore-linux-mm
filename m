Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9A2900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:15:46 -0400 (EDT)
Message-ID: <4E023142.1080605@zytor.com>
Date: Wed, 22 Jun 2011 11:15:30 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
In-Reply-To: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net

On 06/22/2011 04:18 AM, Stefan Assmann wrote:
> 
> The idea is to allow the user to specify RAM addresses that shouldn't be
> touched by the OS, because they are broken in some way. Not all machines have
> hardware support for hwpoison, ECC RAM, etc, so here's a solution that allows to
> use bitmasks to mask address patterns with the new "badram" kernel command line
> parameter.
> Memtest86 has an option to generate these patterns since v2.3 so the only thing
> for the user to do should be:
> - run Memtest86
> - note down the pattern
> - add badram=<pattern> to the kernel command line
> 

We already support the equivalent functionality with
memmap=<address>$<length> for those with only a few ranges... this has
been supported for ages, literally.  For those with a lot of ranges,
like Google, the command line is insufficient.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
