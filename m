Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA3B6B0266
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 16:06:16 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id x25so255730uax.16
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 13:06:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d67sor6187734vka.238.2018.01.10.13.06.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 13:06:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
 <1515531365-37423-5-git-send-email-keescook@chromium.org> <alpine.DEB.2.20.1801101219390.7926@nuc-kabylake>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 10 Jan 2018 13:06:13 -0800
Message-ID: <CAGXu5j+BcHbg4z_zZO8fsjFvQ1TCVvC1TH3d8J=1qXusAqXwLw@mail.gmail.com>
Subject: Re: [PATCH 04/36] usercopy: Prepare for usercopy whitelisting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-xfs@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Network Development <netdev@vger.kernel.org>, kernel-hardening@lists.openwall.com

On Wed, Jan 10, 2018 at 10:28 AM, Christopher Lameter <cl@linux.com> wrote:
> On Tue, 9 Jan 2018, Kees Cook wrote:
>
>> +struct kmem_cache *kmem_cache_create_usercopy(const char *name,
>> +                     size_t size, size_t align, slab_flags_t flags,
>> +                     size_t useroffset, size_t usersize,
>> +                     void (*ctor)(void *));
>
> Hmmm... At some point we should switch kmem_cache_create to pass a struct
> containing all the parameters. Otherwise the API will blow up with
> additional functions.
>
>> index 2181719fd907..70c4b4bb4d1f 100644
>> --- a/include/linux/stddef.h
>> +++ b/include/linux/stddef.h
>> @@ -19,6 +19,8 @@ enum {
>>  #define offsetof(TYPE, MEMBER)       ((size_t)&((TYPE *)0)->MEMBER)
>>  #endif
>>
>> +#define sizeof_field(structure, field) sizeof((((structure *)0)->field))
>> +
>>  /**
>>   * offsetofend(TYPE, MEMBER)
>>   *
>
> Have a separate patch for adding this functionality? Its not a slab
> maintainer
> file.

Good idea; I've done this now.

> Rest looks ok.
>
> Acked-by: Christoph Lameter <cl@linux.com>

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
