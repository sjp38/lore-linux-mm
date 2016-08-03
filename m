Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0980E828E1
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 19:47:09 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so424047474pfg.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 16:47:09 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id uw3si11238854pac.158.2016.08.03.16.47.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 16:47:08 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id iw10so78063170pac.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 16:47:08 -0700 (PDT)
Date: Wed, 3 Aug 2016 16:47:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: Drop bogus inline for fixup_red_left()
In-Reply-To: <1470256262-1586-1-git-send-email-geert@linux-m68k.org>
Message-ID: <alpine.DEB.2.10.1608031646540.29237@chino.kir.corp.google.com>
References: <1470256262-1586-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531376392-911293448-1470268026=:29237"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531376392-911293448-1470268026=:29237
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Wed, 3 Aug 2016, Geert Uytterhoeven wrote:

> With m68k-linux-gnu-gcc-4.1:
> 
>     include/linux/slub_def.h:126: warning: a??fixup_red_lefta?? declared inline after being called
>     include/linux/slub_def.h:126: warning: previous declaration of a??fixup_red_lefta?? was here
> 
> Commit c146a2b98eb5898e ("mm, kasan: account for object redzone in
> SLUB's nearest_obj()") made fixup_red_left() global, but forgot to
> remove the inline keyword.
> 
> Fixes: c146a2b98eb5898e ("mm, kasan: account for object redzone in SLUB's nearest_obj()")
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: David Rientjes <rientjes@google.com>
--531376392-911293448-1470268026=:29237--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
