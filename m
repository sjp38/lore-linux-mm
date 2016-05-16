Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A99B36B007E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 09:54:48 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id tb5so59946337lbb.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:54:48 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id 193si20229664wmh.122.2016.05.16.06.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 06:54:47 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id w143so18245302wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 06:54:47 -0700 (PDT)
Date: Mon, 16 May 2016 15:54:42 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv8 resend 2/2] selftest/x86: add mremap vdso test
Message-ID: <20160516135442.GA14452@gmail.com>
References: <1462886951-23376-1-git-send-email-dsafonov@virtuozzo.com>
 <1462886951-23376-2-git-send-email-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462886951-23376-2-git-send-email-dsafonov@virtuozzo.com>
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

Can the segfault be caught and recovered from, to print a proper failure message?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
