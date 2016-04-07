Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 09DC66B0253
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 12:35:48 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id fp4so56359866obb.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 09:35:48 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id e8si3123719obp.53.2016.04.07.09.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 09:35:47 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id y204so105630581oie.3
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 09:35:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460045867.2818.67.camel@debian.org>
References: <1459971348-81477-1-git-send-email-thgarnie@google.com>
	<CAGXu5jLEENTFL_NYA5r4SqmUefkEwL68_Br6bX_RY2xNv95GVg@mail.gmail.com>
	<1460045867.2818.67.camel@debian.org>
Date: Thu, 7 Apr 2016 09:35:46 -0700
Message-ID: <CAJcbSZFx4rT6fXKvOF-wgHTSZBgqfQGw0qn=JqwAygNHDVUvNQ@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC v1] mm: SLAB freelist randomization
From: Thomas Garnier <thgarnie@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yves-Alexis Perez <corsac@debian.org>
Cc: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Laura Abbott <labbott@fedoraproject.org>

That's a use after free. The randomization of the freelist should not
have much effect on that. I was going to quote this exploit that is
applicable to SLAB as well:
https://jon.oberheide.org/blog/2010/09/10/linux-kernel-can-slub-overflow

Regards.
Thomas

On Thu, Apr 7, 2016 at 9:17 AM, Yves-Alexis Perez <corsac@debian.org> wrote:
> On mer., 2016-04-06 at 14:45 -0700, Kees Cook wrote:
>> > This security feature reduces the predictability of
>> > the kernel slab allocator against heap overflows.
>>
>> I would add "... rendering attacks much less stable." And if you can
>> find a specific example exploit that is foiled by this, I would refer
>> to it.
>
> One good example might (or might not) be the keyring issue from earlier this
> year (CVE-2016-0728):
>
> http://perception-point.io/2016/01/14/analysis-and-exploitation-of-a-linux-ker
> nel-vulnerability-cve-2016-0728/
>
> Regards,
> --
> Yves-Alexis
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
