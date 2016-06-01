Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id E92776B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 12:43:37 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id j12so12634074lbo.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 09:43:37 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id l8si30455900wjm.189.2016.06.01.09.43.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 09:43:36 -0700 (PDT)
Date: Wed, 1 Jun 2016 10:43:33 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 7/8] pkeys: add details of system call use to
 Documentation/
Message-ID: <20160601104333.7c2014fa@lwn.net>
In-Reply-To: <20160531152824.2B18E890@viggo.jf.intel.com>
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
	<20160531152824.2B18E890@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On Tue, 31 May 2016 08:28:24 -0700
Dave Hansen <dave@sr71.net> wrote:

> +There are 5 system calls which directly interact with pkeys:
> +
> +	int pkey_alloc(unsigned long flags, unsigned long init_access_rights)
> +	int pkey_free(int pkey);
> +	int sys_pkey_mprotect(unsigned long start, size_t len,
> +			      unsigned long prot, int pkey);
> +	unsigned long pkey_get(int pkey);
> +	int pkey_set(int pkey, unsigned long access_rights);

sys_pkey_mprotect() should just be pkey_mprotect(), right?

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
