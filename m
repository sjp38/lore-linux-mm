Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAB1F6B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 12:26:04 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d62so369694049iof.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 09:26:04 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0113.outbound.protection.outlook.com. [157.55.234.113])
        by mx.google.com with ESMTPS id cl20si6033573obb.41.2016.05.16.09.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 May 2016 09:26:04 -0700 (PDT)
Subject: Re: [PATCHv8 resend 2/2] selftest/x86: add mremap vdso test
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
 <1462886951-23376-2-git-send-email-dsafonov@virtuozzo.com>
 <20160516135442.GA14452@gmail.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <512f4c9c-7edc-0d12-df96-9708df5f498d@virtuozzo.com>
Date: Mon, 16 May 2016 19:24:49 +0300
MIME-Version: 1.0
In-Reply-To: <20160516135442.GA14452@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On 05/16/2016 04:54 PM, Ingo Molnar wrote:
>
> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>
>> Should print on success:
>> [root@localhost ~]# ./test_mremap_vdso_32
>> 	AT_SYSINFO_EHDR is 0xf773f000
>> [NOTE]	Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
>> [OK]
>> Or segfault if landing was bad (before patches):
>> [root@localhost ~]# ./test_mremap_vdso_32
>> 	AT_SYSINFO_EHDR is 0xf774f000
>> [NOTE]	Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
>> Segmentation fault (core dumped)
>
> Can the segfault be caught and recovered from, to print a proper failure message?

Will add segfault handler, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
