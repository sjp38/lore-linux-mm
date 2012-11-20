Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 49C396B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 17:25:52 -0500 (EST)
Date: Tue, 20 Nov 2012 14:25:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PART4 Patch v2 1/2] numa: add CONFIG_MOVABLE_NODE for
 movable-dedicated node
Message-Id: <20121120142550.5c126194.akpm@linux-foundation.org>
In-Reply-To: <1353067090-19468-2-git-send-email-wency@cn.fujitsu.com>
References: <1353067090-19468-1-git-send-email-wency@cn.fujitsu.com>
	<1353067090-19468-2-git-send-email-wency@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rob Landley <rob@landley.net>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On Fri, 16 Nov 2012 19:58:09 +0800
Wen Congyang <wency@cn.fujitsu.com> wrote:

> From: Lai Jiangshan <laijs@cn.fujitsu.com>
> 
> All are prepared, we can actually introduce N_MEMORY.
> add CONFIG_MOVABLE_NODE make we can use it for movable-dedicated node

This description is far too short on details.

I grabbed this from the [0/n] email:

: We need a node which only contains movable memory.  This feature is very
: important for node hotplug.  If a node has normal/highmem, the memory may
: be used by the kernel and can't be offlined.  If the node only contains
: movable memory, we can offline the memory and the node.

which helps a bit, but it's still pretty thin.

Why is this option made configurable?  Why not enable it unconditionally?

Please send a patch which adds the Kconfig help text for
CONFIG_MOVABLE_NODE.  Let's make that text nice and detailed.

The name MOVABLE_NODE is not a good one.  It means "a node which is
movable", whereas the concept is actually "a node whcih contains only
movable memory".  I suppose we could change it to something like
CONFIG_MOVABLE_MEMORY_ONLY_NODE or similar.  But I suppose that
CONFIG_MOVABLE_NODE is good enough, as long as it is well-described in
associated comments or help text.  This is not the case at present.

> +#ifdef CONFIG_MOVABLE_NODE
> +	N_MEMORY,		/* The node has memory(regular, high, movable) */
> +#else

I think the comment should be "The node has only movable memory"?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
