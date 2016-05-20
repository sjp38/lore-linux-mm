Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3F7A6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 11:33:25 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r11so2825202itd.2
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:33:25 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id 42si10241776otz.13.2016.05.20.08.33.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 08:33:24 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id x201so184752387oif.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 08:33:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160520064820.GB29418@gmail.com>
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
 <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com> <20160520064820.GB29418@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 20 May 2016 08:33:04 -0700
Message-ID: <CALCETrWznziSzwu3gG6bcFAxPvboTF519iTS6F8+WVW0B4i4UQ@mail.gmail.com>
Subject: Re: [PATCHv9 2/2] selftest/x86: add mremap vdso test
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org

On Thu, May 19, 2016 at 11:48 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dmitry Safonov <dsafonov@virtuozzo.com> wrote:
>
>> Should print on success:
>> [root@localhost ~]# ./test_mremap_vdso_32
>>       AT_SYSINFO_EHDR is 0xf773f000
>> [NOTE]        Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
>> [OK]
>> Or segfault if landing was bad (before patches):
>> [root@localhost ~]# ./test_mremap_vdso_32
>>       AT_SYSINFO_EHDR is 0xf774f000
>> [NOTE]        Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
>> Segmentation fault (core dumped)
>
> So I still think that generating potential segfaults is not a proper way to test a
> new feature. How are we supposed to tell the feature still works? I realize that
> glibc is a problem here - but that doesn't really change the QA equation: we are
> adding new kernel code to help essentially a single application out of tens of
> thousands of applications.
>
> At minimum we should have a robust testcase ...

I think it's robust enough.  It will print "[OK]" and exit with 0 on
success and it will crash on failure.  The latter should cause make
run_tests to fail reliably.

There are some test cases in there that can't avoid crashing on
failure unless they were to fork, fail in a child, and then print some
text in the parent.  That seems like it would be more work than it's
worth.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
