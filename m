Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BE6E16B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:50:53 -0400 (EDT)
Received: by mail-da0-f48.google.com with SMTP id p8so417680dan.35
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:50:52 -0700 (PDT)
Date: Wed, 10 Apr 2013 16:50:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: madvise: complete input validation before taking
 lock
In-Reply-To: <u0leheij6gt.fsf@orc05.imf.au.dk>
Message-ID: <alpine.DEB.2.02.1304101650210.27541@chino.kir.corp.google.com>
References: <u0leheij6gt.fsf@orc05.imf.au.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 10 Apr 2013, Rasmus Villemoes wrote:

> In madvise(), there doesn't seem to be any reason for taking the
> &current->mm->mmap_sem before start and len_in have been
> validated. Incidentally, this removes the need for the out: label.
> 
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Acked-by: David Rientjes <rientjes@google.com>

Would be nice to do s/out_plug/out/ now if you have a chance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
