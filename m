Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8226B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 02:48:27 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ga2so42064518lbc.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 23:48:27 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id b199si2900888wme.74.2016.05.19.23.48.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 23:48:25 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id n129so26603401wmn.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 23:48:25 -0700 (PDT)
Date: Fri, 20 May 2016 08:48:20 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv9 2/2] selftest/x86: add mremap vdso test
Message-ID: <20160520064820.GB29418@gmail.com>
References: <1463487232-4377-1-git-send-email-dsafonov@virtuozzo.com>
 <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463487232-4377-3-git-send-email-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com, luto@amacapital.net, tglx@linutronix.de, hpa@zytor.com, x86@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, 0x7f454c46@gmail.com, Shuah Khan <shuahkh@osg.samsung.com>, linux-kselftest@vger.kernel.org


* Dmitry Safonov <dsafonov@virtuozzo.com> wrote:

> Should print on success:
> [root@localhost ~]# ./test_mremap_vdso_32
> 	AT_SYSINFO_EHDR is 0xf773f000
> [NOTE]	Moving vDSO: [f773f000, f7740000] -> [a000000, a001000]
> [OK]
> Or segfault if landing was bad (before patches):
> [root@localhost ~]# ./test_mremap_vdso_32
> 	AT_SYSINFO_EHDR is 0xf774f000
> [NOTE]	Moving vDSO: [f774f000, f7750000] -> [a000000, a001000]
> Segmentation fault (core dumped)

So I still think that generating potential segfaults is not a proper way to test a 
new feature. How are we supposed to tell the feature still works? I realize that 
glibc is a problem here - but that doesn't really change the QA equation: we are 
adding new kernel code to help essentially a single application out of tens of 
thousands of applications.

At minimum we should have a robust testcase ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
