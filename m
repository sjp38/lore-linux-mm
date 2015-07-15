Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 276BD2802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:56:09 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so45168608iec.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:56:09 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id i4si174733igj.30.2015.07.15.16.56.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:56:08 -0700 (PDT)
Received: by iecuq6 with SMTP id uq6so45168535iec.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:56:08 -0700 (PDT)
Date: Wed, 15 Jul 2015 16:56:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/3] memtest: cleanup log messages
In-Reply-To: <1436863249-1219-3-git-send-email-vladimir.murzin@arm.com>
Message-ID: <alpine.DEB.2.10.1507151655440.9230@chino.kir.corp.google.com>
References: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com> <1436863249-1219-3-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, leon@leon.nu

On Tue, 14 Jul 2015, Vladimir Murzin wrote:

> - prefer pr_info(...  to printk(KERN_INFO ...
> - use %pa for phys_addr_t
> - use cpu_to_be64 while printing pattern in reserve_bad_mem()
> 
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>

Acked-by: David Rientjes <rientjes@google.com>

Not sure why you changed the whitespace in reserve_bad_mem() though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
