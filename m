Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4D2B56B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 13:36:07 -0400 (EDT)
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 10:36:06 -0700
Date: Thu, 17 Jun 2010 10:36:04 -0700
From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: Probable Bug (or configuration error) in kmemleak
Message-ID: <20100617173604.GB28055@tux>
References: <AANLkTikaH5sYv-pa6OEIPCofF8RAbi7F3nTdWqEXWr8J@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <AANLkTikaH5sYv-pa6OEIPCofF8RAbi7F3nTdWqEXWr8J@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Sankar P <sankar.curiosity@gmail.com>
Cc: "rnagarajan@novell.com" <rnagarajan@novell.com>, "teheo@novell.com" <teheo@novell.com>, Catalin Marinas <catalin.marinas@arm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Luis Rodriguez <Luis.Rodriguez@Atheros.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 17, 2010 at 02:21:56AM -0700, Sankar P wrote:
> Hi,
> 
> I wanted to detect memory leaks in one of my kernel modules. So I
> built Linus' tree  with the following config options enabled (on top
> of make defconfig)
> 
> CONFIG_DEBUG_KMEMLEAK=y
> CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=400
> CONFIG_DEBUG_KMEMLEAK_TEST=y
> 
> If I boot with this kernel, debugfs is automatically mounted. But I do
> not have the file:
> 
> /sys/kernel/debug/kmemleak
> 
> created at all. There are other files like kprobes in the mounted
> /sys/kernel/debug directory btw. So I am not able to detect any of the
> memory leaks. Is there anything I am doing wrong or missing (or) is
> this a bug in kmemleak ?
> 
> Please let me know your suggestions to fix this and get memory leaks
> reporting working. Thanks.
> 
> The full .config file is also attached with this mail. Sorry for the
> attachment, I did not want to paste 5k lines in the mail. Sorry if it
> is wrong.


This is odd.. Do you see this message on your kernel ring buffer?

Failed to create the debugfs kmemleak file

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
