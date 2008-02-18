Subject: Re: [BUG] Linux 2.6.25-rc2 - Kernel Ooops while running dbench
In-reply-To: <47B9956B.8060506@garzik.org>
References: <alpine.LFD.1.00.0802151302210.9496@woody.linux-foundation.org> <47B6784E.2090401@linux.vnet.ibm.com> <20080218045954.50503fb1.akpm@linux-foundation.org> <20080218045954.50503fb1.akpm@linux-foundation.org> <47B9956B.8060506@garzik.org>
Message-Id: <E1JR8aj-0004bH-Er@faramir.fjphome.nl>
From: Frans Pop <elendil@planet.nl>
Date: Mon, 18 Feb 2008 17:11:41 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: akpm@linux-foundation.org, apw@shadowen.org, balbir@linux.vnet.ibm.com, clameter@sgi.com, kamalesh@linux.vnet.ibm.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeff Garzik wrote:
> Two x86-64 boxes here lock up here on 2.6.25-rc2, shortly after boot.
> One running Fedora 8 + X (GNOME) and one a headless file server.
> configs and lspci attached.  Unable to capture any splatter so far.

Sounds like it may be http://lkml.org/lkml/2008/2/17/78.

Suggest you try reverting that before doing the bisect.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
