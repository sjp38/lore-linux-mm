Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE996B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 12:49:41 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 132so12655039lfz.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 09:49:41 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id n66si44494692wmg.5.2016.06.01.09.49.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 09:49:40 -0700 (PDT)
Date: Wed, 1 Jun 2016 10:49:37 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 7/8] pkeys: add details of system call use to
 Documentation/
Message-ID: <20160601104937.098a89a2@lwn.net>
In-Reply-To: <574F114F.8010701@sr71.net>
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
	<20160531152824.2B18E890@viggo.jf.intel.com>
	<20160601104333.7c2014fa@lwn.net>
	<574F114F.8010701@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On Wed, 1 Jun 2016 09:46:07 -0700
Dave Hansen <dave@sr71.net> wrote:

> On 06/01/2016 09:43 AM, Jonathan Corbet wrote:
> >> > +There are 5 system calls which directly interact with pkeys:
> >> > +
> >> > +	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
> >> > +	int pkey_free(int pkey);
> >> > +	int sys_pkey_mprotect(unsigned long start, size_t len,
> >> > +			      unsigned long prot, int pkey);
> >> > +	unsigned long pkey_get(int pkey);
> >> > +	int pkey_set(int pkey, unsigned long access_rights);  
> > sys_pkey_mprotect() should just be pkey_mprotect(), right?  
> 
> Yes, and that are a few more instances of that farther down in the file.
>  I'll fix them all up.

While you're at it (I shouldn't have hit send quite so quickly :) 

> +	sys_pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
> +	sys_pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE);
> +	something(ptr);

That should, IMO, be something like:

	key = pkey_alloc(...);
	pkey_mprotect(ptr, size, PROT_READ|PROT_WRITE, key);

?


jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
