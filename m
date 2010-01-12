Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 774226B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 20:39:26 -0500 (EST)
Message-ID: <4B4BD281.4080009@linux.intel.com>
Date: Tue, 12 Jan 2010 02:38:09 +0100
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface /dev/mem
 for 64-bit kernel(v1)
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>	<20100108124851.GB6153@localhost>	<DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>	<20100111124303.GA21408@localhost> <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>


> Hmmm....could you rewrite /dev/mem to use kernel/resource.c other than
> modifing e820 maps. ?

Sorry but responding to bug fixes with "could you please rewrite ..."  is
not considered fair. Shaohui is just trying to fix a bug here, not redesigning
a subsystem.


> Two reasons.
>   - e820map is considerted to be stable, read-only after boot.
>   - We don't need to add more x86 special codes.

We need working memory hotadd.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
