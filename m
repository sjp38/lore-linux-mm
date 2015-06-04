Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8F298900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 14:41:47 -0400 (EDT)
Received: by payr10 with SMTP id r10so34846227pay.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 11:41:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id k9si7106623pdp.27.2015.06.04.11.41.46
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 11:41:46 -0700 (PDT)
Message-ID: <55709BEA.8030903@intel.com>
Date: Thu, 04 Jun 2015 11:41:46 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 08/12] mm: use mirrorable to switch allocate mirrored
 memory
References: <55704A7E.5030507@huawei.com> <55704C79.5060608@huawei.com>
In-Reply-To: <55704C79.5060608@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/04/2015 06:02 AM, Xishi Qiu wrote:
> Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it means
> we should allocate mirrored memory for both user and kernel processes.

That's a pretty dangerously short name. :)

How would this end up getting used?  It seems like it would be dangerous
to use once userspace was very far along.  So would the kernel set it to
1 and then let (early??) userspace set it back to 0?  That would let
important userspace like /bin/init get mirrored memory without having to
actually change much in userspace.

This definitely needs some good documentation.

Also, if it's insane to turn it back *on*, maybe it should be a one-way
trip to turn off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
