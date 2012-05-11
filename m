Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 2AFCD8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 16:39:41 -0400 (EDT)
Date: Fri, 11 May 2012 13:39:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory: add kernelcore_max_addr boot option
Message-Id: <20120511133939.25b5a738.akpm@linux-foundation.org>
In-Reply-To: <4FACA79C.9070103@cn.fujitsu.com>
References: <4FACA79C.9070103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 11 May 2012 13:46:04 +0800
Lai Jiangshan <laijs@cn.fujitsu.com> wrote:

> Current ZONE_MOVABLE (kernelcore=) setting policy with boot option doesn't meet
> our requirement. We need something like kernelcore_max_addr= boot option
> to limit the kernelcore upper address.

Why do you need this?  Please fully describe the requirement/use case.

> The memory with higher address will be migratable(movable) and they
> are easier to be offline(always ready to be offline when the system don't require
> so much memory).
> 
> All kernelcore_max_addr=, kernelcore= and movablecore= can be safely specified
> at the same time(or any 2 of them).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
