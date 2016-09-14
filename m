Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB8366B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 11:58:31 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 192so60971393itm.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 08:58:31 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0098.outbound.protection.outlook.com. [104.47.2.98])
        by mx.google.com with ESMTPS id 5si19388480oih.280.2016.09.14.08.58.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 08:58:17 -0700 (PDT)
Subject: Re: [PATCHv5 0/6] x86: 32-bit compatible C/R on x86_64
References: <20160905133308.28234-1-dsafonov@virtuozzo.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <28071a1b-5f2e-be74-0408-8ec0e26957db@virtuozzo.com>
Date: Wed, 14 Sep 2016 18:56:10 +0300
MIME-Version: 1.0
In-Reply-To: <20160905133308.28234-1-dsafonov@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, x86@kernel.org

On 09/05/2016 04:33 PM, Dmitry Safonov wrote:
> Changes from v4:
> - check both vm_ops and vm_private_data to avoid (unlikely) confusion
>   with some other vma in map_vdso_once (as Andy noticed) - which would
>   lead to unable to use this API in that unlikely-case
>   (vm_private_data may be uninitialized and be the same as vvar_mapping
>   or vdso_mapping pointer) - so I introduced one-liner helper
>   vma_is_special_mapping().
>
> Changes from v3:
> - proper ifdefs around vdso_image_32
> - missed Reviewed-by tag

Ping?
It looks like, all acks are there and there are no objections.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
