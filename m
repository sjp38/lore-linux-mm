Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2706028085D
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:04:42 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r197so2999553iod.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:04:42 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id s75si3616745ioe.370.2017.08.24.05.04.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 05:04:40 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id z129so1490876itc.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:04:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170823153456.b3c50e1ec109fd69f672b348@linux-foundation.org>
References: <20170821183503.12246-1-matthew.auld@intel.com>
 <20170821183503.12246-2-matthew.auld@intel.com> <1503480688.6276.4.camel@linux.intel.com>
 <20170823153456.b3c50e1ec109fd69f672b348@linux-foundation.org>
From: Matthew Auld <matthew.william.auld@gmail.com>
Date: Thu, 24 Aug 2017 13:04:09 +0100
Message-ID: <CAM0jSHMiOKGEEsuxUuX5ayD_eAVByQZaCsE8rs8_XPopxnbcfg@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 01/23] mm/shmem: introduce shmem_file_setup_with_mnt
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, linux-mm@kvack.org, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Matthew Auld <matthew.auld@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>

On 23 August 2017 at 23:34, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Wed, 23 Aug 2017 12:31:28 +0300 Joonas Lahtinen <joonas.lahtinen@linux.intel.com> wrote:
>
>> This patch has been floating around for a while now Acked and without
>> further comments. It is blocking us from merging huge page support to
>> drm/i915.
>>
>> Would you mind merging it, or prodding the right people to get it in?
>>
>> Regards, Joonas
>>
>> On Mon, 2017-08-21 at 19:34 +0100, Matthew Auld wrote:
>> > We are planning to use our own tmpfs mnt in i915 in place of the
>> > shm_mnt, such that we can control the mount options, in particular
>> > huge=, which we require to support huge-gtt-pages. So rather than roll
>> > our own version of __shmem_file_setup, it would be preferred if we could
>> > just give shmem our mnt, and let it do the rest.
>
> hm, it's a bit odd.  I'm having trouble locating the code which handles
> huge=within_size (and any other options?).

See here https://patchwork.freedesktop.org/patch/172771/, currently we
only care about huge=within_size.

> What other approaches were considered?

We also tried https://patchwork.freedesktop.org/patch/156528/, where
it was suggested that we mount our own tmpfs instance.

Following from that we now have our own tmps mnt mounted with
huge=within_size. With this patch we avoid having to roll our own
__shmem_file_setup like in
https://patchwork.freedesktop.org/patch/163024/.

> Was it not feasible to add i915-specific mount options to
> mm/shmem.c (for example?).

Hmm, I think within_size should suffice for our needs.

>
> _______________________________________________
> Intel-gfx mailing list
> Intel-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/intel-gfx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
