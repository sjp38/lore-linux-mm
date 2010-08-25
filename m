Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC546B01F0
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 03:45:17 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [BUGFIX][PATCH 1/2] x86, mem: separate x86_64 vmalloc_sync_all() into separate functions
References: <4C6E4ECD.1090607@linux.intel.com>
Date: Wed, 25 Aug 2010 09:45:13 +0200
In-Reply-To: <4C6E4ECD.1090607@linux.intel.com> (Haicheng Li's message of
	"Fri, 20 Aug 2010 17:45:49 +0800")
Message-ID: <87r5hni19y.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "ak@linux.intel.com" <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Haicheng Li <haicheng.li@linux.intel.com> writes:

> hello,
>
> Resend these two patches for bug fixing:
>
> The bug is that when memory hotplug-adding happens for a large enough area that a new PGD entry is
> needed for the direct mapping, the PGDs of other processes would not get updated. This leads to some
> CPUs oopsing when they have to access the unmapped areas, e.g. onlining CPUs on the new added node.

The patches look good to me. Can we please move forward with this?

Reviewed-by: Andi Kleen <ak@linux.intel.com>

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
