Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 85E766B0062
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:36:39 -0500 (EST)
Date: Fri, 13 Nov 2009 12:36:36 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Allow memory hotplug and hibernation in the same kernel
Message-ID: <20091113113636.GC30880@basil.fritz.box>
References: <20091113105944.GA16028@basil.fritz.box> <20091113200745.33CE.A69D9226@jp.fujitsu.com> <20091113203151.33D1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091113203151.33D1.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, gerald.schaefer@de.ibm.com, rjw@sisk.pl, linux-kernel@vger.kernel.org, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > > This is a 2.6.32 candidate.
> 
> 2.6.32?

Well stable at least. But it's simple enough and fixes an obvious
problem and in fact a regression (old kernels didn't exclude memory hotadd
and hibernation), so it could be even a 2.6.32.0 candidate.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
