Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEF696B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 14:25:33 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id i5so190222428ige.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 11:25:33 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id dq5si8042602oeb.73.2016.05.16.11.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 11:25:32 -0700 (PDT)
Received: by mail-oi0-x229.google.com with SMTP id x201so281521319oif.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 11:25:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <512f4c9c-7edc-0d12-df96-9708df5f498d@virtuozzo.com>
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
 <1462886951-23376-2-git-send-email-dsafonov@virtuozzo.com>
 <20160516135442.GA14452@gmail.com> <512f4c9c-7edc-0d12-df96-9708df5f498d@virtuozzo.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 16 May 2016 11:25:12 -0700
Message-ID: <CALCETrWCPNF8njicMutsWkeHRheDjh14x+Np=pAhMojm2_6AJw@mail.gmail.com>
Subject: Re: [PATCHv8 resend 2/2] selftest/x86: add mremap vdso test
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On Mon, May 16, 2016 at 9:24 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
> On 05/16/2016 04:54 PM, Ingo Molnar wrote:
>>
>>
>> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>>
>>> Should print on success:
>>> [root@localhost ~]# ./test_mremap_vdso_32
>>>         AT_SYSINFO_EHDR is 0xf773f000
>>> [NOTE]  Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
>>> [OK]
>>> Or segfault if landing was bad (before patches):
>>> [root@localhost ~]# ./test_mremap_vdso_32
>>>         AT_SYSINFO_EHDR is 0xf774f000
>>> [NOTE]  Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
>>> Segmentation fault (core dumped)
>>
>>
>> Can the segfault be caught and recovered from, to print a proper failure
>> message?
>
>
> Will add segfault handler, thanks.
>

It may be more complicated that that.  Glibc is likely to explode if
this happens, and the headers are sufficiently screwed up that it's
awkward to bypass glibc and call rt_sigaction directly.  I have a test
that does the latter, though, so it's at least possible, but I'm
unconvinced it's worth it just for an error message.

-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
