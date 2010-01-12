Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 243106B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 20:43:05 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C1h2Es018991
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 10:43:02 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 67A3C45DE4C
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:43:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4833D45DE38
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:43:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 331731DB8038
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:43:02 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 910E1E18003
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:42:58 +0900 (JST)
Date: Tue, 12 Jan 2010 10:39:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel(v1)
Message-Id: <20100112103944.a9b1db76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B4BD281.4080009@linux.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
	<20100108124851.GB6153@localhost>
	<DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
	<20100111124303.GA21408@localhost>
	<20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
	<4B4BD281.4080009@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 02:38:09 +0100
Andi Kleen <ak@linux.intel.com> wrote:

> 
> > Hmmm....could you rewrite /dev/mem to use kernel/resource.c other than
> > modifing e820 maps. ?
> 
> Sorry but responding to bug fixes with "could you please rewrite ..."  is
> not considered fair. Shaohui is just trying to fix a bug here, not redesigning
> a subsystem.
> 
Quick hack for bug fix is okay to me. 

About this patch, I'm not sure whether we are allowed to rewrite e820map after
boot.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
