Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C2A536B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:12:23 -0400 (EDT)
Received: by wijp15 with SMTP id p15so77446467wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:12:23 -0700 (PDT)
Received: from mailrelay.lanline.com (mailrelay.lanline.com. [216.187.10.16])
        by mx.google.com with ESMTPS id e8si21411133wiz.64.2015.08.24.06.12.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 06:12:22 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <21979.6150.929309.800457@quad.stoffel.home>
Date: Mon, 24 Aug 2015 09:11:34 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH 3/3 v4] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <20150824073422.GC13082@gmail.com>
References: <20150823081750.GA28349@gmail.com>
	<20150824010403.27903.qmail@ns.horizon.com>
	<20150824073422.GC13082@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: George Spelvin <linux@horizon.com>, dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

>>>>> "Ingo" == Ingo Molnar <mingo@kernel.org> writes:

Ingo> * George Spelvin <linux@horizon.com> wrote:

>> First, an actual, albeit minor, bug: initializing both vmap_info_gen
>> and vmap_info_cache_gen to 0 marks the cache as valid, which it's not.

Ingo> Ha! :-) Fixed.

>> vmap_info_gen should be initialized to 1 to force an initial
>> cache update.

Blech, it should be initialized with a proper #define
VMAP_CACHE_NEEDS_UPDATE 1, instead of more magic numbers.


Ingo> + */
Ingo> +static DEFINE_SPINLOCK(vmap_info_lock);
Ingo> +static int vmap_info_gen = 1;

   static int vmap_info_gen = VMAP_CACHE_NEEDS_UPDATE;

Ingo> +static int vmap_info_cache_gen;
Ingo> +static struct vmalloc_info vmap_info_cache;
Ingo> +#endif


This will help keep bugs like this out in the future... I hope!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
