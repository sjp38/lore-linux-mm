Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13FC46B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:08:32 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id i32so109144131uai.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:08:32 -0700 (PDT)
Received: from mail-ua0-x22c.google.com (mail-ua0-x22c.google.com. [2607:f8b0:400c:c08::22c])
        by mx.google.com with ESMTPS id w7si193223uaw.207.2016.08.31.08.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 08:08:30 -0700 (PDT)
Received: by mail-ua0-x22c.google.com with SMTP id l94so93775630ual.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:08:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2ec4f6ff-ef2f-f864-e4cc-3b9a547b392b@virtuozzo.com>
References: <20160831135936.2281-1-dsafonov@virtuozzo.com> <20160831135936.2281-4-dsafonov@virtuozzo.com>
 <CAJwJo6bh3fZXjOCZSGC4-=MHCs_2KrpGcEAibvNMZLE5_Wi=Eg@mail.gmail.com>
 <CALCETrVN3eF3YS7PgbsMPH8QMAfHZkMCXm7TPa1abQ4Ai+S-Tw@mail.gmail.com> <2ec4f6ff-ef2f-f864-e4cc-3b9a547b392b@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 31 Aug 2016 08:08:10 -0700
Message-ID: <CALCETrUvTC8DzYjv+bmScP7nDaBaZHkivAXmahC7zePzX3xypg@mail.gmail.com>
Subject: Re: [PATCHv4 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Wed, Aug 31, 2016 at 8:01 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> On 08/31/2016 05:56 PM, Andy Lutomirski wrote:
>>
>> On Wed, Aug 31, 2016 at 7:04 AM, Dmitry Safonov <0x7f454c46@gmail.com>
>> wrote:
>>>
>>> Hi Andy,
>>> can I have your acks for 2-3 patches, or should I fix something else
>>> in those patches?
>>>
>>> 2016-08-31 16:59 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
>>>>
>>>> Add API to change vdso blob type with arch_prctl.
>>>> As this is usefull only by needs of CRIU, expose
>>>> this interface under CONFIG_CHECKPOINT_RESTORE.
>>
>>
>>
>> I thought the vm_file stuff was still being iterated on.  Did I
>> misunderstand?
>
>
> Yep, vm_file is being iterated, separately from vdso-map/compatible
> patches.

OK

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
