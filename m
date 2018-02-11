Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CAF66B0007
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 16:02:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y75so2346775wrc.18
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 13:02:13 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id q5si5215619wrf.390.2018.02.11.13.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 13:02:11 -0800 (PST)
Date: Sun, 11 Feb 2018 13:01:57 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/6] genalloc: selftest
Message-ID: <20180211210157.GB4680@bombadil.infradead.org>
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-3-igor.stoppa@huawei.com>
 <CAOFm3uGNVu87qYzPufu+gGbTwuhp3cjfhKuNDkcmwn3+ysKTdg@mail.gmail.com>
 <f95a064d-75e9-6ff3-2c11-4158a0ad1ca9@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f95a064d-75e9-6ff3-2c11-4158a0ad1ca9@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Philippe Ombredanne <pombredanne@nexb.com>, Igor Stoppa <igor.stoppa@huawei.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, Christoph Hellwig <hch@infradead.org>, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com

On Sun, Feb 11, 2018 at 12:27:14PM -0800, Randy Dunlap wrote:
> On 02/11/18 12:22, Philippe Ombredanne wrote:
> > nit... For a comment in .h this line should be instead its own comment
> > as the first line:
> >> +/* SPDX-License-Identifier: GPL-2.0 */
> 
> Why are we treating header files (.h) differently than .c files?
> Either one can use the C++ "//" comment syntax.

This is now documented!

Documentation/process/license-rules.rst:

   If a specific tool cannot handle the standard comment style, then the
   appropriate comment mechanism which the tool accepts shall be used. This
   is the reason for having the "/\* \*/" style comment in C header
   files. There was build breakage observed with generated .lds files where
   'ld' failed to parse the C++ comment. This has been fixed by now, but
   there are still older assembler tools which cannot handle C++ style
   comments.

Personally, I find this disappointing.  I find this:

// SPDX-License-Identifier: GPL-2.0+
/*
 * XArray implementation
 * Copyright (c) 2017 Microsoft Corporation
 * Author: Matthew Wilcox <mawilcox@microsoft.com>
 */

much less visually appealling than

/*
 * XArray implementation
 * Copyright (c) 2017 Microsoft Corporation
 * Author: Matthew Wilcox <mawilcox@microsoft.com>
 * SPDX-License-Identifier: GPL-2.0+
 */

I can't see this variation making a tag extraction tool harder to write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
