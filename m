Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BA5AE6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 10:18:58 -0400 (EDT)
Date: Mon, 10 Oct 2011 16:18:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] mm: thp: make swap configurable
Message-ID: <20111010141851.GC17335@redhat.com>
References: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com

Hi Bob,

On Mon, Oct 10, 2011 at 09:58:06PM +0800, Bob Liu wrote:
> Currently THP do swap by default, user has no control of it.
> But some applications are swap sensitive, this patch add a boot param
> and sys file to make it configurable.

Why don't you use mlock or swapoff -a? I doubt we want to handle THP
pages differently from regular pages with regard to swap or anything
else, the value is to behave as close as possible to regular
pages. What you want you can already achieve by other means I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
