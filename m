Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 27C476B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 19:50:46 -0400 (EDT)
Date: Wed, 26 Sep 2012 16:50:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Please be aware that __always_inline doesn't mean
 "always inline"!
Message-Id: <20120926165044.46b8f7d6.akpm@linux-foundation.org>
In-Reply-To: <50638DCC.5040506@att.net>
References: <50638DCC.5040506@att.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Santos <daniel.santos@pobox.com>
Cc: Daniel Santos <danielfsantos@att.net>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, torvalds@linux-foundation.org

On Wed, 26 Sep 2012 18:20:44 -0500
Daniel Santos <danielfsantos@att.net> wrote:

> I've noticed that there's a lot of misperception about the meaning of
> the __always_inline, or more specifically,
> __attribute__((always_inline)), which does not actually cause the
> function to always be inlined.  Rather, it *allows* gcc to inline the
> function, even when compiling without optimizations.  Here is the
> description of the attribute from gcc's docs
> (http://gcc.gnu.org/onlinedocs/gcc-4.7.2/gcc/Function-Attributes.html)
> 
> always_inline
> Generally, functions are not inlined unless optimization is specified.
> For functions declared inline, this attribute inlines the function even
> if no optimization level was specified.
> 
> This would even appear to imply that such functions aren't even marked
> as "inline" (something I wasn't aware of until today).  The only
> mechanism I'm currently aware of to force gcc to inline a function is
> the flatten attribute (see https://lkml.org/lkml/2012/9/25/643) which
> works backwards, you declare it on the calling function, and it forces
> gcc to inline all functions (marked as inline) that it calls.

As I mentioned in the other thread, the __always_inline's in fs/namei.c
(at least) are doing exactly what we want them to do, so some more
investigation is needed here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
