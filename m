Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D43726B0260
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:03:50 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p203so8745427oif.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:03:50 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0105.outbound.protection.outlook.com. [104.47.1.105])
        by mx.google.com with ESMTPS id r47si368236otd.179.2016.08.31.08.03.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 08:03:29 -0700 (PDT)
Subject: Re: [PATCHv4 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
References: <20160831135936.2281-1-dsafonov@virtuozzo.com>
 <20160831135936.2281-4-dsafonov@virtuozzo.com>
 <CAJwJo6bh3fZXjOCZSGC4-=MHCs_2KrpGcEAibvNMZLE5_Wi=Eg@mail.gmail.com>
 <CALCETrVN3eF3YS7PgbsMPH8QMAfHZkMCXm7TPa1abQ4Ai+S-Tw@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <2ec4f6ff-ef2f-f864-e4cc-3b9a547b392b@virtuozzo.com>
Date: Wed, 31 Aug 2016 18:01:17 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrVN3eF3YS7PgbsMPH8QMAfHZkMCXm7TPa1abQ4Ai+S-Tw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On 08/31/2016 05:56 PM, Andy Lutomirski wrote:
> On Wed, Aug 31, 2016 at 7:04 AM, Dmitry Safonov <0x7f454c46@gmail.com> wrote:
>> Hi Andy,
>> can I have your acks for 2-3 patches, or should I fix something else
>> in those patches?
>>
>> 2016-08-31 16:59 GMT+03:00 Dmitry Safonov <dsafonov@virtuozzo.com>:
>>> Add API to change vdso blob type with arch_prctl.
>>> As this is usefull only by needs of CRIU, expose
>>> this interface under CONFIG_CHECKPOINT_RESTORE.
>
>
> I thought the vm_file stuff was still being iterated on.  Did I misunderstand?

Yep, vm_file is being iterated, separately from vdso-map/compatible
patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
