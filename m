Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id B09CF6B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 12:46:09 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id q18so43618199igr.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 09:46:09 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id fq10si13846760pac.8.2016.06.01.09.46.08
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 09:46:09 -0700 (PDT)
Subject: Re: [PATCH 7/8] pkeys: add details of system call use to
 Documentation/
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
 <20160531152824.2B18E890@viggo.jf.intel.com>
 <20160601104333.7c2014fa@lwn.net>
From: Dave Hansen <dave@sr71.net>
Message-ID: <574F114F.8010701@sr71.net>
Date: Wed, 1 Jun 2016 09:46:07 -0700
MIME-Version: 1.0
In-Reply-To: <20160601104333.7c2014fa@lwn.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On 06/01/2016 09:43 AM, Jonathan Corbet wrote:
>> > +There are 5 system calls which directly interact with pkeys:
>> > +
>> > +	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
>> > +	int pkey_free(int pkey);
>> > +	int sys_pkey_mprotect(unsigned long start, size_t len,
>> > +			      unsigned long prot, int pkey);
>> > +	unsigned long pkey_get(int pkey);
>> > +	int pkey_set(int pkey, unsigned long access_rights);
> sys_pkey_mprotect() should just be pkey_mprotect(), right?

Yes, and that are a few more instances of that farther down in the file.
 I'll fix them all up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
