Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A9A356B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 10:07:47 -0500 (EST)
Date: Tue, 14 Feb 2012 09:07:44 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
In-Reply-To: <20120214005301.a9d5be1a.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1202140906500.20013@router.home>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com> <20120214005301.a9d5be1a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Bai <hamo.by@gmail.com>, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Feb 2012, Andrew Morton wrote:

> One of the applications of kcalloc() is to prevent userspace from
> causing a multiplicative overflow (and then perhaps causing an
> overwrite beyond the end of the allocated memory).
>
> With this patch, we've just handed the user a way of spamming the logs
> at 1MHz.  This is bad.

Well there is WARN_ON_ONCE too to prevent that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
