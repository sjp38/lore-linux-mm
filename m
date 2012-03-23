Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 286AA6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 16:53:58 -0400 (EDT)
Date: Fri, 23 Mar 2012 13:53:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swapon: check validity of swap_flags
Message-Id: <20120323135356.6b2376d6.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1203231346500.1940@eggly.anvils>
References: <alpine.LSU.2.00.1203231346500.1940@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012 13:48:35 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> Most system calls taking flags first check that the flags passed in are
> valid, and that helps userspace to detect when new flags are supported.
> 
> But swapon never did so: start checking now, to help if we ever want to
> support more swap_flags in future.
> 
> It's difficult to get stray bits set in an int, and swapon is not widely
> used, so this is most unlikely to break any userspace; but we can just
> revert if it turns out to do so.

It would be safer to emit a nasty message then let the swapon proceed
as before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
