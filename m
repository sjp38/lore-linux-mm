Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A58CB6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 06:26:21 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id i75so28807379ioa.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 03:26:21 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0123.outbound.protection.outlook.com. [157.55.234.123])
        by mx.google.com with ESMTPS id j201si941222oib.22.2016.05.17.03.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 May 2016 03:26:20 -0700 (PDT)
Subject: Re: [PATCHv8 resend 2/2] selftest/x86: add mremap vdso test
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
 <1462886951-23376-2-git-send-email-dsafonov@virtuozzo.com>
 <20160516135442.GA14452@gmail.com>
 <512f4c9c-7edc-0d12-df96-9708df5f498d@virtuozzo.com>
 <CALCETrWCPNF8njicMutsWkeHRheDjh14x+Np=pAhMojm2_6AJw@mail.gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <7d74b270-01dd-aab9-8133-249fe9a52767@virtuozzo.com>
Date: Tue, 17 May 2016 13:25:04 +0300
MIME-Version: 1.0
In-Reply-To: <CALCETrWCPNF8njicMutsWkeHRheDjh14x+Np=pAhMojm2_6AJw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On 05/16/2016 09:25 PM, Andy Lutomirski wrote:
> On Mon, May 16, 2016 at 9:24 AM, Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>> On 05/16/2016 04:54 PM, Ingo Molnar wrote:
>>>
>>>
>>> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>>>
>>>> Should print on success:
>>>> [root@localhost ~]# ./test_mremap_vdso_32
>>>>         AT_SYSINFO_EHDR is 0xf773f000
>>>> [NOTE]  Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
>>>> [OK]
>>>> Or segfault if landing was bad (before patches):
>>>> [root@localhost ~]# ./test_mremap_vdso_32
>>>>         AT_SYSINFO_EHDR is 0xf774f000
>>>> [NOTE]  Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
>>>> Segmentation fault (core dumped)
>>>
>>>
>>> Can the segfault be caught and recovered from, to print a proper failure
>>> message?
>>
>>
>> Will add segfault handler, thanks.
>>
>
> It may be more complicated that that.  Glibc is likely to explode if
> this happens, and the headers are sufficiently screwed up that it's
> awkward to bypass glibc and call rt_sigaction directly.  I have a test
> that does the latter, though, so it's at least possible, but I'm
> unconvinced it's worth it just for an error message.

Oh, I didn't know that, thanks, Andy.
I'll leave it as is for simplicity.

-- 
Regards,
Dmitry Safonov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
