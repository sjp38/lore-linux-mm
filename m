Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CC03A6B0047
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 00:47:48 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8E4lkGD017976
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 14 Sep 2010 13:47:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 49CDF45DE6E
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:47:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 25FDB45DE60
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:47:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F668E08001
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:47:46 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C1C371DB8037
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 13:47:45 +0900 (JST)
Date: Tue, 14 Sep 2010 13:42:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] devmem: change vread()/vwrite() prototype to return
 success or error code
Message-Id: <20100914134234.b8d861cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090916014958.722014998@intel.com>
References: <20090916013939.656308742@intel.com>
	<20090916014958.722014998@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Nick Piggin <npiggin@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 09:39:40 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Silently ignore all vmalloc area holes in vread()/vwrite(),
> and report success (or error code in future) to the caller.
> 
> The original intention is to fix a vwrite() related bug, where
> it could return 0 which cannot be handled correctly by its caller
> write_kmem(). Then KAMEZAWA recommends to change the prototype
> to make the semantics clear.
> 
> CC: Andi Kleen <andi@firstfloor.org>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Ingo Molnar <mingo@elte.hu>
> CC: Tejun Heo <tj@kernel.org>
> CC: Nick Piggin <npiggin@suse.de>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Okay, maybe it's good to change for now.

I sometimes wonder we should use copy_to/from_user to access vmalloc area...
but we have IO_REMAP. So, maybe vread/vwrite is required one.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
