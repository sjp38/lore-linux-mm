Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 897E96B000E
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 15:23:16 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q63so7774562wrb.16
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 12:23:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a139sor923574wme.74.2018.02.11.12.23.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 12:23:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180211031920.3424-3-igor.stoppa@huawei.com>
References: <20180211031920.3424-1-igor.stoppa@huawei.com> <20180211031920.3424-3-igor.stoppa@huawei.com>
From: Philippe Ombredanne <pombredanne@nexb.com>
Date: Sun, 11 Feb 2018 21:22:34 +0100
Message-ID: <CAOFm3uGNVu87qYzPufu+gGbTwuhp3cjfhKuNDkcmwn3+ysKTdg@mail.gmail.com>
Subject: Re: [PATCH 2/6] genalloc: selftest
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, Christoph Hellwig <hch@infradead.org>, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com

On Sun, Feb 11, 2018 at 4:19 AM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
> Introduce a set of macros for writing concise test cases for genalloc.
>
> The test cases are meant to provide regression testing, when working on
> new functionality for genalloc.
>
> Primarily they are meant to confirm that the various allocation strategy
> will continue to work as expected.
>
> The execution of the self testing is controlled through a Kconfig option.
>
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

<snip>

> --- /dev/null
> +++ b/include/linux/genalloc-selftest.h
> @@ -0,0 +1,26 @@
> +/* SPDX-License-Identifier: GPL-2.0

nit... For a comment in .h this line should be instead its own comment
as the first line:
> +/* SPDX-License-Identifier: GPL-2.0 */

<snip>

> --- /dev/null
> +++ b/lib/genalloc-selftest.c
> @@ -0,0 +1,400 @@
> +/* SPDX-License-Identifier: GPL-2.0

And for a comment in .c this line should use C++ style as the first line:

> +// SPDX-License-Identifier: GPL-2.0

Please check the docs for this (I know this can feel surprising but
this has been debated at great length on list)

Thank you!
-- 
Cordially
Philippe Ombredanne

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
