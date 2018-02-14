Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id E256D6B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 14:23:49 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id p2so13558203vke.6
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 11:23:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n74sor5423419vka.71.2018.02.14.11.23.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 11:23:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1518634058.3678.15.camel@perches.com>
References: <20180214182618.14627-1-willy@infradead.org> <1518634058.3678.15.camel@perches.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 14 Feb 2018 11:23:47 -0800
Message-ID: <CAGXu5jJdAJt3HK7FgaCyPRbXeFV-hJOrPodNnOkx=kCvSieK3w@mail.gmail.com>
Subject: Re: [PATCH 0/2] Add kvzalloc_struct to complement kvzalloc_array
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 14, 2018 at 10:47 AM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2018-02-14 at 10:26 -0800, Matthew Wilcox wrote:
>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>
>> We all know the perils of multiplying a value provided from userspace
>> by a constant and then allocating the resulting number of bytes.  That's
>> why we have kvmalloc_array(), so we don't have to think about it.
>> This solves the same problem when we embed one of these arrays in a
>> struct like this:
>>
>> struct {
>>       int n;
>>       unsigned long array[];
>> };
>
> I think expanding the number of allocation functions
> is not necessary.

I think removing common mispatterns in favor of overflow-protected
allocation functions makes sense.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
