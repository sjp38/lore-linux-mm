Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 191386B00A9
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 17:00:37 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id t19so8968964igi.0
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 14:00:36 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id nv5si22226745igb.42.2014.03.24.14.00.35
        for <linux-mm@kvack.org>;
        Mon, 24 Mar 2014 14:00:36 -0700 (PDT)
Date: Mon, 24 Mar 2014 16:00:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [mmotm:master 463/499] mm/mprotect.c:46:14: sparse: context
 imbalance in 'lock_pte_protection' - different lock contexts for basic
 block
In-Reply-To: <532e4cc1.umGiNE2YJiL9Z2iq%fengguang.wu@intel.com>
Message-ID: <alpine.DEB.2.10.1403241559390.29809@nuc>
References: <532e4cc1.umGiNE2YJiL9Z2iq%fengguang.wu@intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Sun, 23 Mar 2014, kbuild test robot wrote:

> >> mm/mprotect.c:46:14: sparse: context imbalance in 'lock_pte_protection' - different lock contexts for basic block
> >> arch/x86/include/asm/paravirt.h:699:9: sparse: context imbalance in 'change_pte_range' - unexpected unlock
> --
> >> fs/ntfs/super.c:3100:1: sparse: directive in argument list
> >> fs/ntfs/super.c:3102:1: sparse: directive in argument list
> >> fs/ntfs/super.c:3104:1: sparse: directive in argument list
> >> fs/ntfs/super.c:3105:1: sparse: directive in argument list
> >> fs/ntfs/super.c:3107:1: sparse: directive in argument list
> >> fs/ntfs/super.c:3108:1: sparse: directive in argument list
> >> fs/ntfs/super.c:3110:1: sparse: directive in argument list

Looked through these and I am a bit puzzled how they related to raw cpu
ops patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
