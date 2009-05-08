Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADC326B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 07:49:07 -0400 (EDT)
Date: Fri, 8 May 2009 13:49:36 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 8/8] pagemap: export PG_hwpoison
Message-ID: <20090508114936.GC17129@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111032.121067794@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090508111032.121067794@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> This flag indicates a hardware detected memory corruption on the 
> page. Any future access of the page data may bring down the 
> machine.

NAK on this whole idea, it's utterly harmful. At _minimum_ 
/proc/kpageflags should be moved to /debug/vm/ to not have
any ABI bindings.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
