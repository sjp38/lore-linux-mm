Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 31E402802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:55:42 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so1689856igb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:55:42 -0700 (PDT)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com. [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id ng9si5508188icb.4.2015.07.15.16.55.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 16:55:41 -0700 (PDT)
Received: by iggf3 with SMTP id f3so1651322igg.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:55:41 -0700 (PDT)
Date: Wed, 15 Jul 2015 16:55:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/3] memtest: use kstrtouint instead of
 simple_strtoul
In-Reply-To: <1436863249-1219-2-git-send-email-vladimir.murzin@arm.com>
Message-ID: <alpine.DEB.2.10.1507151655290.9230@chino.kir.corp.google.com>
References: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com> <1436863249-1219-2-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, leon@leon.nu

On Tue, 14 Jul 2015, Vladimir Murzin wrote:

> Since simple_strtoul is obsolete and memtest_pattern is type of int, use
> kstrtouint instead.
> 
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
