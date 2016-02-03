Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C2EEB828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 13:19:10 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p63so178044454wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 10:19:10 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id b25si2020694wmi.28.2016.02.03.10.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 10:19:09 -0800 (PST)
Subject: Re: linux-next: Tree for Feb 3 (mm, hugepage)
References: <20160203161811.621b399a@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <56B24498.4040402@infradead.org>
Date: Wed, 3 Feb 2016 10:19:04 -0800
MIME-Version: 1.0
In-Reply-To: <20160203161811.621b399a@canb.auug.org.au>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 02/02/16 21:18, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20160202:
> 

on x86_64:

when CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is enabled
and CONFIG_TRANSPARENT_HUGEPAGE is not enabled:

../fs/proc/task_mmu.c: In function 'smaps_pud_range':
../fs/proc/task_mmu.c:596:2: error: implicit declaration of function 'is_huge_zero_pud' [-Werror=implicit-function-declaration]
  if (is_huge_zero_pud(*pud))
  ^



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
