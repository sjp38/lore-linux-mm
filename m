Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1C6C280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 04:52:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so72743553pfd.2
        for <linux-mm@kvack.org>; Sat, 20 May 2017 01:52:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 3si10386442pga.160.2017.05.20.01.51.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 May 2017 01:51:59 -0700 (PDT)
Date: Sat, 20 May 2017 10:51:47 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [kernel-hardening] [PATCH 1/1] Sealable memory support
Message-ID: <20170520085147.GA4619@kroah.com>
References: <20170519103811.2183-1-igor.stoppa@huawei.com>
 <20170519103811.2183-2-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170519103811.2183-2-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: mhocko@kernel.org, dave.hansen@intel.com, labbott@redhat.com, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org

On Fri, May 19, 2017 at 01:38:11PM +0300, Igor Stoppa wrote:
> Dynamically allocated variables can be made read only,
> after they have been initialized, provided that they reside in memory
> pages devoid of any RW data.
> 
> The implementation supplies means to create independent pools of memory,
> which can be individually created, sealed/unsealed and destroyed.
> 
> A global pool is made available for those kernel modules that do not
> need to manage an independent pool.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  mm/Makefile  |   2 +-
>  mm/smalloc.c | 200 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/smalloc.h |  61 ++++++++++++++++++
>  3 files changed, 262 insertions(+), 1 deletion(-)
>  create mode 100644 mm/smalloc.c
>  create mode 100644 mm/smalloc.h

This is really nice, do you have a follow-on patch showing how any of
the kernel can be changed to use this new subsystem?  Without that, it
might be hard to get this approved (we don't like adding new apis
without users.)

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
