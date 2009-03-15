Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 866F46B003D
	for <linux-mm@kvack.org>; Sun, 15 Mar 2009 06:28:06 -0400 (EDT)
Date: Sun, 15 Mar 2009 10:27:51 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] [ARM] Flush only the needed range when unmapping a VMA
Message-ID: <20090315102751.GD3963@n2100.arm.linux.org.uk>
References: <49B54B2A.9090408@nokia.com> <1236690093-3037-1-git-send-email-Aaro.Koskinen@nokia.com> <20090312213006.GN7854@n2100.arm.linux.org.uk> <49BA4541.6000708@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49BA4541.6000708@nokia.com>
Sender: owner-linux-mm@kvack.org
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 13, 2009 at 01:36:33PM +0200, Aaro Koskinen wrote:
> shm segment size 4096000 bytes
> real    0m 0.12s
> user    0m 0.02s
> sys     0m 0.10s
> shm segment size 8192000 bytes
> real    0m 0.36s
> user    0m 0.00s
> sys     0m 0.35s
...
> shm segment size 4096000 bytes
> real    0m 0.07s
> user    0m 0.01s
> sys     0m 0.05s
> shm segment size 8192000 bytes
> real    0m 0.13s
> user    0m 0.02s
> sys     0m 0.10s

Yes, that's quite a speedup.  Can you provide some words in the patch
description which indicate that we have about a 3x speed increase for
8M mappings, which only gets better for larger mappings?

Given that this patch is now only touching ARM, is there any need to
indicate that it was CC'd to Hugh when it gets committed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
