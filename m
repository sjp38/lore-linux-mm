Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id BA8A882F66
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 16:32:23 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so1052176igb.0
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:32:23 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id 89si8830346ioq.34.2015.10.21.13.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 13:32:23 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so66986345pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:32:22 -0700 (PDT)
Date: Wed, 21 Oct 2015 13:32:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: initialize kmem_cache pointer to NULL
In-Reply-To: <20151020220411.GA19775@gmail.com>
Message-ID: <alpine.DEB.2.10.1510211332080.31868@chino.kir.corp.google.com>
References: <20151020220411.GA19775@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Oct 2015, Alexandru Moise wrote:

> The assignment to NULL within the error condition was written
> in a 2014 patch to suppress a compiler warning.
> However it would be cleaner to just initialize the kmem_cache
> to NULL and just return it in case of an error condition.
> 
> Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
