Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 6C4836B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 10:03:39 -0500 (EST)
Date: Tue, 14 Feb 2012 09:03:36 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
In-Reply-To: <1329204499-2671-1-git-send-email-hamo.by@gmail.com>
Message-ID: <alpine.DEB.2.00.1202140902400.20013@router.home>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Bai <hamo.by@gmail.com>
Cc: penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Feb 2012, Yang Bai wrote:

> Before, if the total alloc size is overflow,
> we just return NULL like alloc fail. But they
> are two different type problems. The former looks
> more like a programming problem. So add a warning
> here.

Acked-by: Christoph Lameter <cl@linux.com>

Would be better to remove kcalloc and provide a generalized array size
calculation function that does the WARN(). That would also work for all
other variants zeroed or NUMA node spec etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
