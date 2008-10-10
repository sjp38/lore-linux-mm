Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9A7LOBK002007
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Oct 2008 16:21:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 77FD01B801E
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 16:21:24 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 511512DC01D
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 16:21:24 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BB901DB8043
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 16:21:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id CA0841DB8040
	for <linux-mm@kvack.org>; Fri, 10 Oct 2008 16:21:20 +0900 (JST)
Date: Fri, 10 Oct 2008 16:21:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [rfc] approach to pull writepage out of reclaim
Message-Id: <20081010162103.7c8b61c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081009144103.GE9941@wotan.suse.de>
References: <20081009144103.GE9941@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Oct 2008 16:41:03 +0200
Nick Piggin <npiggin@suse.de> wrote:

> Hi,
> 
> Just got bored of looking at other things, and started coding up the first
> step to remove writepage from vmscan.
> 
Can I make a question ? Is this "vmscan" here means

  - direct memory reclaim triggered by memory allocation failure (alloc_pages())
and not
  - kswapd
  - memory resource controller hits its limit

or including all memory reclaim path ?

Thanks
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
