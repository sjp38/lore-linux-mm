Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E46E56B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:59:59 -0400 (EDT)
Message-ID: <49BE4D0E.8010006@nokia.com>
Date: Mon, 16 Mar 2009 14:58:54 +0200
From: Aaro Koskinen <aaro.koskinen@nokia.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [ARM] Flush only the needed range when unmapping a VMA
References: <49B54B2A.9090408@nokia.com> <1236690093-3037-1-git-send-email-Aaro.Koskinen@nokia.com> <20090312213006.GN7854@n2100.arm.linux.org.uk> <49BA4541.6000708@nokia.com> <20090315102751.GD3963@n2100.arm.linux.org.uk>
In-Reply-To: <20090315102751.GD3963@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: ext Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.arm.linux.org.uk" <linux-arm-kernel@lists.arm.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

ext Russell King - ARM Linux wrote:
> Yes, that's quite a speedup.  Can you provide some words in the patch
> description which indicate that we have about a 3x speed increase for
> 8M mappings, which only gets better for larger mappings?

Ok, I will resend the patch with updated description.

> Given that this patch is now only touching ARM, is there any need to
> indicate that it was CC'd to Hugh when it gets committed?

Probably no...

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
