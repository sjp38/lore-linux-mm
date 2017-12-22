Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 691496B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 19:20:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so1466780pgv.17
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:20:58 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id t25si6747328pge.369.2017.12.21.16.20.56
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 16:20:57 -0800 (PST)
Date: Fri, 22 Dec 2017 09:21:09 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: ACPI issues on cold power on [bisected]
Message-ID: <20171222002108.GB1729@js1304-P5Q-DELUXE>
References: <20171208151159.urdcrzl5qpfd6jnu@earth.li>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208151159.urdcrzl5qpfd6jnu@earth.li>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan McDowell <noodles@earth.li>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 08, 2017 at 03:11:59PM +0000, Jonathan McDowell wrote:
> I've been sitting on this for a while and should have spent time to
> investigate sooner, but it's been an odd failure mode that wasn't quite
> obvious.
> 
> In 4.9 if I cold power on my laptop (Dell E7240) it fails to boot - I
> don't see anything after grub says its booting. In 4.10 onwards the
> laptop boots, but I get an Oops as part of the boot and ACPI is unhappy
> (no suspend, no clean poweroff, no ACPI buttons). The Oops is below;
> taken from 4.12 as that's the most recent error dmesg I have saved but
> also seen back in 4.10. It's always address 0x30 for the dereference.
> 
> Rebooting the laptop does not lead to these problems; it's *only* from a
> complete cold boot that they arise (which didn't help me in terms of
> being able to reliably bisect). Once I realised that I was able to
> bisect, but it leads me to an odd commit:
> 
> 86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6
> (mm/slab: fix kmemcg cache creation delayed issue)
> 
> If I revert this then I can cold boot without problems.
> 
> Also I don't see the problem with a stock Debian kernel, I think because
> the ACPI support is modularised.

Hello,

Sorry for late response. I was on a long vacation.

I have tried to solve the problem however I don't find any clue yet.

>From my analysis, oops report shows that 'struct sock *ssk' passed to
netlink_broadcast_filtered() is NULL. It means that some of
netlink_kernel_create() returns NULL. Maybe, it is due to slab
allocation failure. Could you check it by inserting some log on that
part? The issue cannot be reproducible in my side so I need your help.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
