Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 762014403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 17:22:46 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id 65so56955558pfd.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 14:22:46 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 10si17757819pfk.172.2016.02.04.14.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 14:22:45 -0800 (PST)
Received: by mail-pa0-x22c.google.com with SMTP id ho8so22419427pac.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 14:22:45 -0800 (PST)
Date: Thu, 4 Feb 2016 14:22:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] powerpc: query dynamic DEBUG_PAGEALLOC setting
In-Reply-To: <1454565386-10489-5-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1602041422330.29117@chino.kir.corp.google.com>
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com> <1454565386-10489-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 4 Feb 2016, Joonsoo Kim wrote:

> We can disable debug_pagealloc processing even if the code is complied
> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
> whether it is enabled or not in runtime.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
