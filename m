Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id AA3826B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 15:53:27 -0500 (EST)
Date: Mon, 19 Nov 2012 12:53:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] Add movablecore_map boot option.
Message-Id: <20121119125325.ed1abba0.akpm@linux-foundation.org>
In-Reply-To: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1353335246-9127-1-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, yinghai@kernel.org, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Mon, 19 Nov 2012 22:27:21 +0800
Tang Chen <tangchen@cn.fujitsu.com> wrote:

> This patchset provide a boot option for user to specify ZONE_MOVABLE memory
> map for each node in the system.
> 
> movablecore_map=nn[KMG]@ss[KMG]
> 
> This option make sure memory range from ss to ss+nn is movable memory.
> 1) If the range is involved in a single node, then from ss to the end of
>    the node will be ZONE_MOVABLE.
> 2) If the range covers two or more nodes, then from ss to the end of
>    the node will be ZONE_MOVABLE, and all the other nodes will only
>    have ZONE_MOVABLE.
> 3) If no range is in the node, then the node will have no ZONE_MOVABLE
>    unless kernelcore or movablecore is specified.
> 4) This option could be specified at most MAX_NUMNODES times.
> 5) If kernelcore or movablecore is also specified, movablecore_map will have
>    higher priority to be satisfied.
> 6) This option has no conflict with memmap option.

This doesn't describe the problem which the patchset solves.  I can
kinda see where it's coming from, but it would be nice to have it all
spelled out, please.

- What is wrong with the kernel as it stands?
- What are the possible ways of solving this?
- Describe the chosen way, explain why it is superior to alternatives

The amount of manual system configuration in this proposal looks quite
high.  Adding kernel boot parameters really is a last resort.  Why was
it unavoidable here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
