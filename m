Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 81ABE6B0092
	for <linux-mm@kvack.org>; Mon, 14 May 2012 12:52:23 -0400 (EDT)
Date: Mon, 14 May 2012 18:52:21 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [Patch 3/4] memblock: limit memory address from memblock
Message-ID: <20120514165221.GA14426@merkur.ravnborg.org>
References: <4FACA79C.9070103@cn.fujitsu.com> <4FB0F174.1000400@jp.fujitsu.com> <4FB0F37E.2040805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB0F37E.2040805@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, May 14, 2012 at 08:58:54PM +0900, Yasuaki Ishimatsu wrote:
> Setting kernelcore_max_pfn means all memory which is bigger than
> the boot parameter is allocated as ZONE_MOVABLE. So memory which
> is allocated by memblock also should be limited by the parameter.
>
> The patch limits memory from memblock.

I see no reason why we need two limits for memblock.
And if we really require two limits then please use a function
to set it.
All other setup/etc. towoards memblock is via function,
and starting to introduce magic variables is confusing.

Also new stuff in memblock shal have a nice comment
describing the usage. that we in the past has failed to
do so is no excuse.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
