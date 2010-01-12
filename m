Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 649A66B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 19:33:55 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C0Xj7U013056
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 09:33:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D67345DE66
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:33:45 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EC3DD45DE55
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:33:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CD0E1EF8005
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:33:44 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E3C41DB803C
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:33:44 +0900 (JST)
Date: Tue, 12 Jan 2010 09:30:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel(v1)
Message-Id: <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100111124303.GA21408@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
	<20100108124851.GB6153@localhost>
	<DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
	<20100111124303.GA21408@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 20:43:03 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> > > +	/* if add to low memory, update max_low_pfn */
> > > +	if (unlikely(start_pfn < limit_low_pfn)) {
> > > +		if (end_pfn <= limit_low_pfn)
> > > +			max_low_pfn = end_pfn;
> > > +		else
> > > +			max_low_pfn = limit_low_pfn;
> > 
> > X86_64 actually always set max_low_pfn=max_pfn, in setup_arch():
> > [Zheng, Shaohui] there should be some misunderstanding, I read the
> > code carefully, if the total memory is under 4G, it always
> > max_low_pfn=max_pfn. If the total memory is larger than 4G,
> > max_low_pfn means the end of low ram. It set
> 
> > max_low_pfn = e820_end_of_low_ram_pfn();.
> 
> The above line is very misleading.. In setup_arch(), it will be
> overrode by the following block.
> 

Hmmm....could you rewrite /dev/mem to use kernel/resource.c other than
modifing e820 maps. ?
Two reasons.
  - e820map is considerted to be stable, read-only after boot.
  - We don't need to add more x86 special codes.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
