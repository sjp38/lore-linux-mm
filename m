Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 44F9B900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 09:08:59 -0400 (EDT)
Message-ID: <4DAC37E7.5010809@tilera.com>
Date: Mon, 18 Apr 2011 09:08:55 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] tile: replace mm->cpu_vm_mask with mm_cpumask()
References: <20110418211455.9359.A69D9226@jp.fujitsu.com> <20110418211914.9361.A69D9226@jp.fujitsu.com>
In-Reply-To: <20110418211914.9361.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>

On 4/18/2011 8:18 AM, KOSAKI Motohiro wrote:
> We plan to change mm->cpu_vm_mask definition later. Thus, this patch convert
> it into proper macro.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Chris Metcalf <cmetcalf@tilera.com>

Thanks; I wasn't aware of this macro.  I'll take this change into my tree
unless you would like to push it.

> Chris, I couldn't get cross compiler for tile. thus I hope you check it carefully.

The toolchain support is currently only available from Tilera (at
http://www.tilera.com/scm/) but we are in the process of cleaning it up to
push it up to the community.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
