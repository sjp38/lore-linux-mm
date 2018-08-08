Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 01BAD6B000A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 05:05:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g15-v6so677104edm.11
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 02:05:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38-v6si3138013edq.417.2018.08.08.02.05.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Aug 2018 02:05:01 -0700 (PDT)
Subject: Re: [4.18 rc7] BUG: sleeping function called from invalid context at
 mm/slab.h:421
From: Vlastimil Babka <vbabka@suse.cz>
References: <CABXGCsNAjrwat-Fv6GQXq8uSC6uj=ke87RJt42syrfFi0vQUmg@mail.gmail.com>
 <bd7f3ea4-d9a8-e437-9936-ee4513b47ac1@suse.cz>
Message-ID: <50f14cef-9c30-7984-bef3-6da033d91483@suse.cz>
Date: Wed, 8 Aug 2018 11:05:00 +0200
MIME-Version: 1.0
In-Reply-To: <bd7f3ea4-d9a8-e437-9936-ee4513b47ac1@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm@kvack.org, Petr Mladek <pmladek@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On 08/08/2018 11:01 AM, Vlastimil Babka wrote:
> fbcon_startup() calls kzalloc(sizeof(struct fbcon_ops), GFP_KERNEL) so
> it tells slab it can sleep. The problem must be higher in the stack,
> CCing printk people.

Uh just noticed there was also attached dmesg which my reply converted
to inline. The first problem there is a lockdep splat.
