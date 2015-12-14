Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 976E46B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:11:21 -0500 (EST)
Received: by lbblt2 with SMTP id lt2so108827601lbb.3
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:11:21 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id os7si17270293lbb.143.2015.12.14.07.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:11:20 -0800 (PST)
Received: by lbbcs9 with SMTP id cs9so107746601lbb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:11:19 -0800 (PST)
Date: Mon, 14 Dec 2015 18:11:16 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 1/2] [RFC] mm: Account anon mappings as RLIMIT_DATA
Message-ID: <20151214151116.GE14045@uranus>
References: <20151213201646.839778758@gmail.com>
 <20151214145126.GC3604@chrystal.uk.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214145126.GC3604@chrystal.uk.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 14, 2015 at 03:51:26PM +0100, Quentin Casasnovas wrote:
...
> 
> Do we want to fold may_expand_anon_vm() into may_expand_vm() (potentially
> passing it the flags/struct file if needed) so there is just one such
> helper function?  Rationale being that it then gets hard to see what
> restricts what, and it's easy to miss one place.

I tried to make the patch small as possible (because otherwise indeed
I would have to pass @vm_file|@file as additional argument). This won't
be a problem but may_expand_vm is called way more times than
may_expand_anon_vm. That's the only rationale I followed.

> For example, I couldn't find anything preventing a user to
> mmap(MAP_GROWSDOWN) and uses that as a base to get pages that would not be
> accounted for in your patch (making it a poor-man mremap()).

growsup/down stand for stack usage iirc, so it was intentionally
not accounted here.

> 
> I only had a quick look so apologies if this is handled and I missed it :)

thanks for feedback! also take a look on Kostya's patch, I think it's
even better approach (and I like it more than mine).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
