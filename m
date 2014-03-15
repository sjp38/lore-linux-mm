Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4CAF66B003A
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 15:25:40 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so11687205qgd.1
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 12:25:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k45si5684401qgd.142.2014.03.15.12.25.39
        for <linux-mm@kvack.org>;
        Sat, 15 Mar 2014 12:25:39 -0700 (PDT)
Message-ID: <5324A92A.3040309@redhat.com>
Date: Sat, 15 Mar 2014 15:25:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] powerpc/mm: Make sure a local_irq_disable prevent a parallel
 THP split
References: <1394880478-770-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1394880478-770-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/15/2014 06:47 AM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We have generic code like the one in get_futex_key that assume that
> a local_irq_disable prevents a parallel THP split. Support that by
> adding a dummy smp call function after setting _PAGE_SPLITTING. Code
> paths like get_user_pages_fast still need to check for _PAGE_SPLITTING
> after disabling IRQ which indicate that a parallel THP splitting is
> ongoing. Now if they don't find _PAGE_SPLITTING set, then we can be
> sure that parallel split will now block in pmdp_splitting flush
> until we enables IRQ
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
