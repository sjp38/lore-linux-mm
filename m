Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5F76B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 07:02:08 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id g10so10877493pdj.6
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 04:02:07 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id n3si8285807pap.106.2015.01.08.04.02.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 04:02:05 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so10883613pdb.4
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 04:02:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1420421851-3281-3-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com> <1420421851-3281-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 8 Jan 2015 12:01:43 +0000
Message-ID: <CAHkRjk6Lfm4aOHaw6M7ug6DxvmKr1RtuqzfB6k2moJW9VvHAUQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] mm/slab: remove kmemleak_erase() call
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jesper Dangaard Brouer <brouer@redhat.com>

On 5 January 2015 at 01:37, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> We already call kmemleak_no_scan() in initialization step of array cache,
> so kmemleak doesn't scan array cache. Therefore, we don't need to call
> kmemleak_erase() here.
>
> And, this call is the last caller of kmemleak_erase(), so remove
> kmemleak_erase() definition completely.

Good point.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
