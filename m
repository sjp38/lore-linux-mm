Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 075626B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:43:11 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id p83-v6so4178628vkf.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:43:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8-v6sor3588038vka.254.2018.06.07.13.43.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 13:43:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJt_Y5KJwCKVPpTFOBt36aDAG9TqbB2bWAdu+2oGV5cZg@mail.gmail.com>
References: <20180607145720.22590-1-willy@infradead.org> <20180607145720.22590-2-willy@infradead.org>
 <CAGXu5jJt_Y5KJwCKVPpTFOBt36aDAG9TqbB2bWAdu+2oGV5cZg@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Jun 2018 13:43:08 -0700
Message-ID: <CAGXu5j+X1BrPhtdOP9AJ-oSovoHcS1CQHNsiFisdQt=Th7LgWw@mail.gmail.com>
Subject: Re: [PATCH 1/6] Convert virtio_console to struct_size
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, Jun 7, 2018 at 12:29 PM, Kees Cook <keescook@chromium.org> wrote:
> On Thu, Jun 7, 2018 at 7:57 AM, Matthew Wilcox <willy@infradead.org> wrote:
>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>
>> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
>> ---
>>  drivers/char/virtio_console.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
>> index 21085515814f..4bf7c06c2343 100644
>> --- a/drivers/char/virtio_console.c
>> +++ b/drivers/char/virtio_console.c
>> @@ -433,8 +433,7 @@ static struct port_buffer *alloc_buf(struct virtio_device *vdev, size_t buf_size
>>          * Allocate buffer and the sg list. The sg list array is allocated
>>          * directly after the port_buffer struct.
>>          */
>> -       buf = kmalloc(sizeof(*buf) + sizeof(struct scatterlist) * pages,
>> -                     GFP_KERNEL);
>> +       buf = kmalloc(struct_size(buf, sg, pages), GFP_KERNEL);
>>         if (!buf)
>>                 goto fail;
>
> I feel like this one should have been caught by Coccinelle... maybe
> the transitive case got missed? Regardless, I'll figure out how to
> improve the script and/or take these.

Oh, duh. Got it: "struct scatterlist" is not an expression, it's a
type. I'll adjust the script, catch stragglers, and incorporate your
patches. :)

Thanks!

-Kees

-- 
Kees Cook
Pixel Security
