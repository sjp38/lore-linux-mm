Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF666B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 16:02:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so51526603pfa.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 13:02:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gm2si5678629pac.159.2016.07.12.13.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 13:02:03 -0700 (PDT)
Date: Tue, 12 Jul 2016 13:02:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 1/2] mm, kasan: account for object redzone in SLUB's
 nearest_obj()
Message-Id: <20160712130201.9339f7dbc9575d2c0cb31aeb@linux-foundation.org>
In-Reply-To: <1468347165-41906-2-git-send-email-glider@google.com>
References: <1468347165-41906-1-git-send-email-glider@google.com>
	<1468347165-41906-2-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 12 Jul 2016 20:12:44 +0200 Alexander Potapenko <glider@google.com> wrote:

> When looking up the nearest SLUB object for a given address, correctly
> calculate its offset if SLAB_RED_ZONE is enabled for that cache.

What are the runtime effects of this fix?  Please always include this
info when fixing bugs so that others can decide which kernel(s) need
patching.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
