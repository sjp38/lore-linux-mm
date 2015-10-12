Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id EFCF06B0254
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 06:22:09 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so11541567wic.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 03:22:09 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id fu3si18690332wjb.150.2015.10.12.03.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 03:22:08 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] arm: add __initbss section attribute
Date: Mon, 12 Oct 2015 12:21:16 +0200
Message-ID: <8530796.1MzFUDEUSY@wuerfel>
In-Reply-To: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com>
References: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: linux@arm.linux.org.uk, ard.biesheuvel@linaro.org, will.deacon@arm.com, nico@linaro.org, keescook@chromium.org, catalin.marinas@arm.com, victor.kamensky@linaro.org, msalter@redhat.com, vladimir.murzin@arm.com, ggdavisiv@gmail.com, paul.gortmaker@windriver.com, mingo@kernel.org, rusty@rustcorp.com.au, mcgrof@suse.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, jack@suse.cz, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Monday 12 October 2015 11:59:16 yalin wang wrote:
> This attribute can make init data to be into .initbss section,
> this will make the data to be NO_BITS in vmlinux, can shrink the
> Image file size, and speed up the boot up time.
> 
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

Do you have an estimate of how much it gains?

In multi_v7_defconfig, I see a total of 3367 symbols with
406016 bytes init.data, but only 348 bytes of those are
in zero-initialized symbols.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
