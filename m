Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1913F6B0255
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 09:17:01 -0400 (EDT)
Received: by lbcjc2 with SMTP id jc2so5494564lbc.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 06:17:00 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id cd10si4609620wib.23.2015.09.09.06.16.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 06:16:59 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so116162206wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 06:16:59 -0700 (PDT)
Date: Wed, 9 Sep 2015 14:16:57 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v2 1/3] efi: Add EFI_MEMORY_MORE_RELIABLE support to
 efi_md_typeattr_format()
Message-ID: <20150909131657.GF4973@codeblueprint.co.uk>
References: <1440609031-14695-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440609079-14746-1-git-send-email-izumi.taku@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440609079-14746-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, x86@kernel.org, matt.fleming@intel.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org

On Thu, 27 Aug, at 02:11:19AM, Taku Izumi wrote:
> UEFI spec 2.5 introduces new Memory Attribute Definition named
> EFI_MEMORY_MORE_RELIABLE. This patch adds this new attribute
> support to efi_md_typeattr_format().
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>  drivers/firmware/efi/efi.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)

Thanks, applied!

-- 
Matt Fleming, Intel Open Source Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
