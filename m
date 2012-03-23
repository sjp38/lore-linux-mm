Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 21A526B00EA
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 17:20:59 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so3984641ghr.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 14:20:58 -0700 (PDT)
Date: Fri, 23 Mar 2012 14:20:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swapon: check validity of swap_flags
In-Reply-To: <20120323135356.6b2376d6.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1203231416260.2235@eggly.anvils>
References: <alpine.LSU.2.00.1203231346500.1940@eggly.anvils> <20120323135356.6b2376d6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 23 Mar 2012, Andrew Morton wrote:
> On Fri, 23 Mar 2012 13:48:35 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > Most system calls taking flags first check that the flags passed in are
> > valid, and that helps userspace to detect when new flags are supported.
> > 
> > But swapon never did so: start checking now, to help if we ever want to
> > support more swap_flags in future.
> > 
> > It's difficult to get stray bits set in an int, and swapon is not widely
> > used, so this is most unlikely to break any userspace; but we can just
> > revert if it turns out to do so.
> 
> It would be safer to emit a nasty message then let the swapon proceed
> as before.

Safer, I suppose, but I really don't expect that case to arise (we'll
have been doing those lovely runtime discards without asking for a year
now if so).  And it does spoil the checking of supported flags.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
