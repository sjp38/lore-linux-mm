Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 204F26B0071
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 13:18:21 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so12014174pdj.29
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 10:18:20 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rf3si15863882pab.152.2014.11.03.10.18.19
        for <linux-mm@kvack.org>;
        Mon, 03 Nov 2014 10:18:19 -0800 (PST)
Message-ID: <5457C6EA.3080809@intel.com>
Date: Mon, 03 Nov 2014 10:18:18 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Documentation: vm: Add 1GB large page support information
References: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
In-Reply-To: <1414771317-5721-1-git-send-email-standby24x7@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>, corbet@lwn.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lcapitulino@redhat.com

On 10/31/2014 09:01 AM, Masanari Iida wrote:
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -2,7 +2,8 @@
>  The intent of this file is to give a brief summary of hugetlbpage support in
>  the Linux kernel.  This support is built on top of multiple page size support
>  that is provided by most modern architectures.  For example, i386
> -architecture supports 4K and 4M (2M in PAE mode) page sizes, ia64
> +architecture supports 4K and 4M (2M in PAE mode) page sizes, x86_64
> +architecture supports 4K, 2M and 1G (SandyBridge or later) page sizes. ia64
>  architecture supports multiple page sizes 4K, 8K, 64K, 256K, 1M, 4M, 16M,
>  256M and ppc64 supports 4K and 16M.  A TLB is a cache of virtual-to-physical
>  translations.  Typically this is a very scarce resource on processor.

I wouldn't mention SandyBridge.  Not all x86 CPUs are Intel. :)

Also, what of the Intel CPUs like the Xeon Phi or the Atom cores?  I
have an IvyBridge (>= Sandybridge) mobile CPU in this laptop which does
not support 1G pages.

I would axe the i386-specific reference and just say something generic like:

       For example, x86 CPUs normally support 4K and 2M (1G sometimes).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
