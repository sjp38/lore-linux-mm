Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id AE2AA6B0031
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 03:46:13 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id fa1so2850902pad.6
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 00:46:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id eq15si7168803pac.222.2014.06.14.00.46.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Jun 2014 00:46:12 -0700 (PDT)
Message-ID: <539BFDBA.8000806@oracle.com>
Date: Sat, 14 Jun 2014 15:46:02 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: correct return errno on slab_sysfs_init failure
References: <5399A360.3060309@oracle.com> <alpine.DEB.2.10.1406131050430.913@gentwo.org>
In-Reply-To: <alpine.DEB.2.10.1406131050430.913@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com


On 06/13/2014 23:53 PM, Christoph Lameter wrote:
> 
> On Thu, 12 Jun 2014, Jeff Liu wrote:
> 
>> From: Jie Liu <jeff.liu@oracle.com>
>>
>> Return ENOMEM instead of ENOSYS if slab_sysfs_init() failed
> 
> The reason that I used ENOSYS there is that the whole sysfs portion of the
> slab allocator will be disabled. Could be due to a number of issues since
> kset_create_and_add() returns NULL for any error.

Thanks for your clarification and sorry for the noise.

Cheers,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
