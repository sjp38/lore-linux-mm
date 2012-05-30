Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E620C6B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:31:22 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/6] mempolicy: Kill all mempolicy sharing
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
	<1338368529-21784-3-git-send-email-kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 13:31:22 -0700
In-Reply-To: <1338368529-21784-3-git-send-email-kosaki.motohiro@gmail.com>
	(kosaki motohiro's message of "Wed, 30 May 2012 05:02:05 -0400")
Message-ID: <m2vcjdjtr9.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

kosaki.motohiro@gmail.com writes:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Dave Jones' system call fuzz testing tool "trinity" triggered the following
> bug error with slab debugging enabled

We have to fix it properly sorry. There are users who benefit from it
and just disabling it is not gonna fly.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
