Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 4D04A6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:56:54 -0400 (EDT)
Received: by mail-vb0-f42.google.com with SMTP id p12so851997vbe.15
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:56:53 -0700 (PDT)
Message-ID: <5165FC42.6060304@gmail.com>
Date: Wed, 10 Apr 2013 19:56:50 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: madvise: complete input validation before taking
 lock
References: <u0leheij6gt.fsf@orc05.imf.au.dk>
In-Reply-To: <u0leheij6gt.fsf@orc05.imf.au.dk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com

(4/10/13 7:45 PM), Rasmus Villemoes wrote:
> In madvise(), there doesn't seem to be any reason for taking the
> &current->mm->mmap_sem before start and len_in have been
> validated. Incidentally, this removes the need for the out: label.
> 
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Looks good.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
