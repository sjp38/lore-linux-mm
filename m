Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD1046B0260
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 08:17:07 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l125so82886503ywb.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:17:07 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id l62si1851481qke.229.2016.07.08.05.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 05:17:07 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id r68so8299302qka.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:17:07 -0700 (PDT)
Date: Fri, 8 Jul 2016 14:17:04 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv10 2/2] selftest/x86: add mremap vdso test
Message-ID: <20160708121704.GA31371@gmail.com>
References: <20160628113539.13606-1-dsafonov@virtuozzo.com>
 <20160628113539.13606-3-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160628113539.13606-3-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, mingo@redhat.com, luto@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Shuah Khan <shuahkh@osg.samsung.com>, x86@kernel.org, linux-kselftest@vger.kernel.org


* Dmitry Safonov <dsafonov@virtuozzo.com> wrote:

> Or print that mremap for vDSO is unsupported:
> [root@localhost ~]# ./test_mremap_vdso_32
> 	AT_SYSINFO_EHDR is 0xf773c000
> [NOTE]	Moving vDSO: [0xf773c000, 0xf773d000] -> [0xf7737000, 0xf7738000]
> [FAIL]	mremap() of the vDSO does not work on this kernel!

Hm, I tried this on a 64-bit kernel and got:

triton:~/tip/tools/testing/selftests/x86> ./test_mremap_vdso_32 
        AT_SYSINFO_EHDR is 0xf7773000
[NOTE]  Moving vDSO: [0xf7773000, 0xf7774000] -> [0xf776e000, 0xf776f000]
Segmentation fault

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
