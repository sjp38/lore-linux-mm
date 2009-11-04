Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB416B0062
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 16:02:25 -0500 (EST)
Subject: Re: [MM] Remove rss batching from copy_page_range()
From: Andi Kleen <andi@firstfloor.org>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
	<alpine.DEB.1.10.0911041415480.7409@V090114053VZO-1>
Date: Wed, 04 Nov 2009 22:02:20 +0100
In-Reply-To: <alpine.DEB.1.10.0911041415480.7409@V090114053VZO-1> (Christoph Lameter's message of "Wed, 4 Nov 2009 14:17:24 -0500 (EST)")
Message-ID: <87my3280mb.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> writes:

> From: Christoph Lameter <cl@linux-foundation.org>
> Subject: Remove rss batching from copy_page_range()
>
> With per cpu counters in mm there is no need for batching
> mm counter updates anymore. Update counters directly while
> copying pages.

Hmm, but with all the inlining with some luck the local
counters will be in registers. That will never be the case
with the per cpu counters.

So I'm not sure it's really an improvement?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
