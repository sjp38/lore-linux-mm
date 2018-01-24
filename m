Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC8D3800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 03:45:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p7so1892247wre.18
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:45:30 -0800 (PST)
Received: from lb3-smtp-cloud9.xs4all.net (lb3-smtp-cloud9.xs4all.net. [194.109.24.30])
        by mx.google.com with ESMTPS id 92si1388889ede.216.2018.01.24.00.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 00:45:29 -0800 (PST)
Message-ID: <1516783522.2230.6.camel@tiscali.nl>
Subject: Re: [PATCH v6 05/99] xarray: Add definition of struct xarray
From: Paul Bolle <pebolle@tiscali.nl>
Date: Wed, 24 Jan 2018 09:45:22 +0100
In-Reply-To: <20180117202203.19756-6-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
	 <20180117202203.19756-6-willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org

Mathhew,

Just a minor question.

On Wed, 2018-01-17 at 12:20 -0800, Matthew Wilcox wrote:
> This is a direct replacement for struct radix_tree_root.  Some of the
> struct members have changed name; convert those, and use a #define so
> that radix_tree users continue to work without change.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

> --- a/include/linux/xarray.h
> +++ b/include/linux/xarray.h
> @@ -10,6 +10,8 @@
>   */
>  
>  #include <linux/bug.h>
> +#include <linux/compiler.h>
> +#include <linux/kconfig.h>

The top Makefile includes linux/kconfig.h globally. (See the odd USERINCLUDE
variable, which is actually part of the LINUXINCLUDE variable, but split off
to make things confusing.)

Why do you need to include linux/kconfig.h here?

>  #include <linux/spinlock.h>
>  #include <linux/types.h>

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
