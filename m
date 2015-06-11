Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id A8C7C6B006C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 21:02:04 -0400 (EDT)
Received: by qgep100 with SMTP id p100so21671103qge.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 18:02:04 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id n74si10466025qgd.119.2015.06.10.18.02.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 18:02:03 -0700 (PDT)
Received: by qkoo18 with SMTP id o18so33862650qko.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 18:02:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150611005956.GA515@swordfish>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1433851493-23685-5-git-send-email-sergey.senozhatsky@gmail.com>
 <CALZtONAyQn1qGusF4TXcS1FHmiHNmJT+Wrh2G6j7OYA=R+Q0dQ@mail.gmail.com>
 <20150610235836.GB499@swordfish> <1433983686.32331.35.camel@perches.com> <20150611005956.GA515@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 10 Jun 2015 21:01:42 -0400
Message-ID: <CALZtONCWAEP9MvWdNQRtqKG=RiTE8_vqvxkscd3h8_g9XA04ng@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/5] mm/zpool: allow NULL `zpool' pointer in zpool_destroy_pool()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joe Perches <joe@perches.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jun 10, 2015 at 8:59 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (06/10/15 17:48), Joe Perches wrote:
> [..]
>> > > > For consistency, tweak zpool_destroy_pool() and NULL-check the
>> > > > pointer there.
>> > > >
>> > > > Proposed by Andrew Morton.
>> > > >
>> > > > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>> > > > Reported-by: Andrew Morton <akpm@linux-foundation.org>
>> > > > LKML-reference: https://lkml.org/lkml/2015/6/8/583
>> > >
>> > > Acked-by: Dan Streetman <ddstreet@ieee.org>
>> >
>> > Thanks.
>> >
>> > Shall we ask Joe to add zpool_destroy_pool() to the
>> > "$func(NULL) is safe and this check is probably not required" list?
>>
>> []
>>
>> Is it really worth it?
>>
>> There isn't any use of zpool_destroy_pool preceded by an if
>> There is one and only one use of zpool_destroy_pool.
>>
>
> Yes, that's why I asked. I don't think that zpool_destroy_pool()
> will gain any significant amount of users soon (well, who knows),
> so I'm fine with keeping it out of checkpatch checks. Just checked
> your opinion.

I really doubt if zpool will be used by anyone other than zswap anytime soon.

>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
