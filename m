Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E05D46B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 20:37:13 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id en1so1955821wid.15
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:37:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hk1si12234871wjc.73.2013.11.21.17.37.12
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 17:37:12 -0800 (PST)
Date: Thu, 21 Nov 2013 20:37:07 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] mm/bootmem.c: remove unused 'limit' variable
Message-ID: <20131121203707.4f59f86e@redhat.com>
In-Reply-To: <528E83B6.5040107@intel.com>
References: <20131121164335.066fd6aa@redhat.com>
	<528E83B6.5040107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Thu, 21 Nov 2013 14:05:42 -0800
Dave Hansen <dave.hansen@intel.com> wrote:

> On 11/21/2013 01:43 PM, Luiz Capitulino wrote:
> > @@ -655,9 +655,7 @@ restart:
> >  void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
> >  					unsigned long goal)
> >  {
> > -	unsigned long limit = 0;
> > -
> > -	return ___alloc_bootmem_nopanic(size, align, goal, limit);
> > +	return ___alloc_bootmem_nopanic(size, align, goal, 0);
> >  }
> 
> FWIW, I like those.  The way you leave it:
> 
> 	return ___alloc_bootmem_nopanic(size, align, goal, 0);
> 
> the 0 is a magic number that you have to go look up the declaration of
> ___alloc_bootmem_nopanic() to decipher, or you have to add a comment to
> it in some way.
> 
> I find it much more readable to have an 'unused' variable like that.

Got it. I was reading that code and thought 'limit' was a leftover,
so I posted the patch...

Btw, I also have a patch consitfying some zone access functions
parameters that are read-only. Wondering if anyone will object
to such a change? Or maybe I should just stop doing trivial patches :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
