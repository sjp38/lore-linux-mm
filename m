Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 151A86B00B7
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 11:40:29 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id dc16so988580qab.20
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 08:40:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c110si12565350qge.77.2014.11.06.08.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 08:40:27 -0800 (PST)
Date: Thu, 6 Nov 2014 11:40:05 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH/v2] Documentation: vm: Add 1GB large page support
 information
Message-ID: <20141106114005.34dcbf6c@redhat.com>
In-Reply-To: <1415287875-18820-1-git-send-email-standby24x7@gmail.com>
References: <545AADCC.5030102@intel.com>
	<1415287875-18820-1-git-send-email-standby24x7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: linux-kernel@vger.kernel.org, corbet@lwn.net, linux-mm@kvack.org, dave.hansen@intel.com, andi@firstfloor.org

On Fri,  7 Nov 2014 00:31:15 +0900
Masanari Iida <standby24x7@gmail.com> wrote:

> This patch adds 1GB large page support information in
> Documentation/vm/hugetlbpage.txt
> 
> Reference:
> https://lkml.org/lkml/2014/10/31/366
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>
> ---
>  Documentation/vm/hugetlbpage.txt | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index b64e0af..f2d3a10 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -1,8 +1,8 @@
>  
>  The intent of this file is to give a brief summary of hugetlbpage support in
>  the Linux kernel.  This support is built on top of multiple page size support
> -that is provided by most modern architectures.  For example, i386
> -architecture supports 4K and 4M (2M in PAE mode) page sizes, ia64
> +that is provided by most modern architectures.  For example, x86 CPUs normally
> +support 4K and 2M (1G if architecturally supported) page sizes, ia64
>  architecture supports multiple page sizes 4K, 8K, 64K, 256K, 1M, 4M, 16M,
>  256M and ppc64 supports 4K and 16M.  A TLB is a cache of virtual-to-physical
>  translations.  Typically this is a very scarce resource on processor.

Looks good to me:

Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
