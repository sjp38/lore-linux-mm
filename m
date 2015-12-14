Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 832CA6B0258
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:43:17 -0500 (EST)
Received: by lbbcs9 with SMTP id cs9so108476385lbb.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:43:17 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id 7si17321050lff.184.2015.12.14.07.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:43:16 -0800 (PST)
Received: by lfcy184 with SMTP id y184so49857642lfc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:43:16 -0800 (PST)
Date: Mon, 14 Dec 2015 18:43:13 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 1/2] [RFC] mm: Account anon mappings as RLIMIT_DATA
Message-ID: <20151214154313.GF14045@uranus>
References: <20151213201646.839778758@gmail.com>
 <20151214145126.GC3604@chrystal.uk.oracle.com>
 <20151214151116.GE14045@uranus>
 <20151214153234.GE3604@chrystal.uk.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214153234.GE3604@chrystal.uk.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 14, 2015 at 04:32:34PM +0100, Quentin Casasnovas wrote:
> > 
> > growsup/down stand for stack usage iirc, so it was intentionally
> > not accounted here.
> >
> 
> Right, but in the same vein of Linus saying RLIMIT_DATA is/was useless
> because everyone could use mmap() instead of brk() to get anonymous memory,
> what's the point of restricting "almost-all" anonymous memory if one can
> just use MAP_GROWSDOWN/UP and cause repeated page faults to extend that
> mapping, circumventing your checks?  That makes the new restriction as
> useless as what RLIMIT_DATA used to be, doesn't it?

Not as it were before, but true, using growsdown/up will give a way
to allocate memory not limited byt rlimit-data. (Also I just noted
that I modified mm.h as well, where anon_accountable_mapping
was implemented but forgot to add it into quilt, so this patch
on its own won't compile, don't apply it).

> > > 
> > > I only had a quick look so apologies if this is handled and I missed it :)
> > 
> > thanks for feedback! also take a look on Kostya's patch, I think it's
> > even better approach (and I like it more than mine).
> 
> Ha I'm not subscribed to LKML so I missed those, I suppose you can ignore
> my comments then! :)

https://lkml.org/lkml/2015/12/14/72

Take a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
