Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 429786B0100
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 09:25:05 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id u7so8196612qaz.41
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 06:25:05 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z6si29799187qck.3.2014.11.03.06.25.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 06:25:04 -0800 (PST)
Date: Mon, 3 Nov 2014 09:24:57 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] Documentation: vm: Add 1GB large page support
 information
Message-ID: <20141103092457.66577a21@redhat.com>
In-Reply-To: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
References: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: corbet@lwn.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat,  1 Nov 2014 01:01:57 +0900
Masanari Iida <standby24x7@gmail.com> wrote:

> This patch add 1GB large page support information on
> x86_64 architecture in Documentation/vm/hugetlbpage.txt.
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  Documentation/vm/hugetlbpage.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index bdd4bb9..0a2bf4f 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -2,7 +2,8 @@
>  The intent of this file is to give a brief summary of hugetlbpage support in
>  the Linux kernel.  This support is built on top of multiple page size support
>  that is provided by most modern architectures.  For example, i386
> -architecture supports 4K and 4M (2M in PAE mode) page sizes, ia64
> +architecture supports 4K and 4M (2M in PAE mode) page sizes, x86_64
> +architecture supports 4K, 2M and 1G (SandyBridge or later) page sizes. ia64

Good catch, but does it make sense to mention SandyBridge? Doesn't it makes
it Intel specific? What about mentioning the pdpe1gb flag instead?

>  architecture supports multiple page sizes 4K, 8K, 64K, 256K, 1M, 4M, 16M,
>  256M and ppc64 supports 4K and 16M.  A TLB is a cache of virtual-to-physical
>  translations.  Typically this is a very scarce resource on processor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
