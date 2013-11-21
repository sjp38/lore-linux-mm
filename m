Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D8C396B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 17:06:46 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so355437pde.34
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 14:06:46 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id m10si5317398pac.19.2013.11.21.14.06.45
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 14:06:45 -0800 (PST)
Message-ID: <528E83B6.5040107@intel.com>
Date: Thu, 21 Nov 2013 14:05:42 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/bootmem.c: remove unused 'limit' variable
References: <20131121164335.066fd6aa@redhat.com>
In-Reply-To: <20131121164335.066fd6aa@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On 11/21/2013 01:43 PM, Luiz Capitulino wrote:
> @@ -655,9 +655,7 @@ restart:
>  void * __init __alloc_bootmem_nopanic(unsigned long size, unsigned long align,
>  					unsigned long goal)
>  {
> -	unsigned long limit = 0;
> -
> -	return ___alloc_bootmem_nopanic(size, align, goal, limit);
> +	return ___alloc_bootmem_nopanic(size, align, goal, 0);
>  }

FWIW, I like those.  The way you leave it:

	return ___alloc_bootmem_nopanic(size, align, goal, 0);

the 0 is a magic number that you have to go look up the declaration of
___alloc_bootmem_nopanic() to decipher, or you have to add a comment to
it in some way.

I find it much more readable to have an 'unused' variable like that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
