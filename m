Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id CC52D6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:10:02 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so14155887wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 01:10:02 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id qo6si8837889wjc.79.2016.03.17.01.10.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 01:10:01 -0700 (PDT)
Subject: Re: [PATCH] UBIFS: Implement ->migratepage()
References: <201603171228.iwNVzwZx%fengguang.wu@intel.com>
From: Richard Weinberger <richard@nod.at>
Message-ID: <56EA6653.6050504@nod.at>
Date: Thu, 17 Mar 2016 09:09:55 +0100
MIME-Version: 1.0
In-Reply-To: <201603171228.iwNVzwZx%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Am 17.03.2016 um 05:39 schrieb kbuild test robot:
> Hi Kirill,
> 
> [auto build test ERROR on v4.5-rc7]
> [also build test ERROR on next-20160316]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Richard-Weinberger/UBIFS-Implement-migratepage/20160317-065742
> config: x86_64-allmodconfig (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>>> ERROR: "migrate_page_move_mapping" [fs/ubifs/ubifs.ko] undefined!
>>> ERROR: "migrate_page_copy" [fs/ubifs/ubifs.ko] undefined!

Meh. Just noticted that these functions are not exported and therefore not
usable in modules.
So, this patch is not really the solution although it makes the problem go away.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
