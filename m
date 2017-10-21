Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 520B96B0266
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 23:04:13 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e89so12594241ioi.16
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 20:04:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c189sor63412ith.74.2017.10.20.20.04.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 20:04:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0015a75a-3624-2ec7-ae21-4753cf072e61@redhat.com>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <0ad1f8b1-3c9f-adb0-35c3-18619ff5aa25@redhat.com> <0015a75a-3624-2ec7-ae21-4753cf072e61@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 20 Oct 2017 20:04:11 -0700
Message-ID: <CAGXu5jKtNqnDA_vU5KaPuVJNCK0hBMGgYh6Ut0BVHvpu315XnA@mail.gmail.com>
Subject: Re: [PATCH 00/23] Hardened usercopy whitelisting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 20, 2017 at 4:25 PM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> On 21/10/2017 00:40, Paolo Bonzini wrote:
>> This breaks KVM completely on x86, due to two ioctls
>> (KVM_GET/SET_CPUID2) accessing the cpuid_entries field of struct
>> kvm_vcpu_arch.
>>
>> There's also another broken ioctl, KVM_XEN_HVM_CONFIG, but it is
>> obsolete and not a big deal at all.
>>
>> I can post some patches, but probably not until the beginning of
>> November due to travelling.  Please do not send this too close to the
>> beginning of the merge window.
>
> Sleeping is overrated, sending patches now...

Oh awesome, thank you very much for tracking this down and building fixes!

I'll insert these into the usercopy whitelisting series, and see if I
can find any similar cases.

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
