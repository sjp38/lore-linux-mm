Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EED9C6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 07:11:06 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d139so29118402oig.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 04:11:06 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0146.outbound.protection.outlook.com. [157.56.112.146])
        by mx.google.com with ESMTPS id c203si2711160oif.119.2016.05.11.04.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 May 2016 04:11:05 -0700 (PDT)
Subject: Re: [PATCH] mm-kasan-initial-memory-quarantine-implementation-v8-fix
References: <1462887534-30428-1-git-send-email-aryabinin@virtuozzo.com>
 <CAG_fn=UdD=gvFXOSMh3b+PzHerh6HD0ydrDYTEeXf1gPgMuBZw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57331368.9070101@virtuozzo.com>
Date: Wed, 11 May 2016 14:11:36 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UdD=gvFXOSMh3b+PzHerh6HD0ydrDYTEeXf1gPgMuBZw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>

On 05/11/2016 01:18 PM, Alexander Potapenko wrote:
> On Tue, May 10, 2016 at 3:38 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>  * Fix comment styles,
>  yDid you remove the comments from include/linux/kasan.h because they
> were put inconsistently, or was there any other reason?

We usually comment functions near definition, not declarations.
If you like, put comment back. Just place it near definition.

>>  * Get rid of some ifdefs
> Thanks!
>>  * Revert needless functions renames in quarantine patch
> I believe right now the names are somewhat obscure. I agree however
> the change should be done in a separate patch.

Besides that, I didn't like the fact that you made names longer and exceeded
80-char limit in some places.

>>  * Remove needless local_irq_save()/restore() in per_cpu_remove_cache()
> Ack
>>  * Add new 'struct qlist_node' instead of 'void **' types. This makes
>>    code a bit more redable.
> Nice, thank you!
> 
> How do I incorporate your changes? Is it ok if I merge it with the
> next version of my patch and add a "Signed-off-by: Andrey Ryabinin
> <aryabinin@virtuozzo.com>" line to the description?
> 

Ok, but I don't think that this is matters. Andrew will just craft a diff patch
on top of the current code anyways.
Or you can make such diff by yourself and send it, it's easier to review, after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
