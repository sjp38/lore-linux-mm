Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 823796B0103
	for <linux-mm@kvack.org>; Wed, 13 May 2009 09:35:10 -0400 (EDT)
Message-ID: <4A0ACCAA.4020505@redhat.com>
Date: Wed, 13 May 2009 09:35:38 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] vmscan: drop PF_SWAPWRITE from zone_reclaim
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120627.587F.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090513120627.587F.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Subject: [PATCH] vmscan: drop PF_SWAPWRITE from zone_reclaim
> 
> PF_SWAPWRITE mean ignore write congestion. (see may_write_to_queue())
> 
> foreground reclaim shouldn't ignore it because to write congested device cause
> large IO lantency.
> it isn't better than remote node allocation.

It might be on NUMAQ (which is no longer manufactured), but
your change looks right for every other vaguely modern NUMA
architecture that I know of.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
