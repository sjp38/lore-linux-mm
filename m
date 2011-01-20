Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A2E2C8D003A
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 13:02:30 -0500 (EST)
Date: Thu, 20 Jan 2011 18:01:46 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
Message-ID: <20110120180146.GH6335@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com> <1295544047.9039.609.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295544047.9039.609.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KyongHo Cho <pullip.cho@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 20, 2011 at 09:20:47AM -0800, Dave Hansen wrote:
> This problem actually exists without sparsemem, too.  Discontigmem (at
> least) does it as well.

We don't expect banks to cross sparsemem boundaries, or the older
discontigmem nodes (esp. as we used to store the node number.)
Discontigmem support has been removed now so that doesn't apply
anymore.

> The x86 version of show_mem() actually manages to do this without any
> #ifdefs, and works for a ton of configuration options.  It uses
> pfn_valid() to tell whether it can touch a given pfn.

x86 memory layout tends to be very simple as it expects memory to
start at the beginning of every region described by a pgdat and extend
in one contiguous block.  I wish ARM was that simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
