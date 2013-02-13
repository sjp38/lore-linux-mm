Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DDEC96B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 19:19:14 -0500 (EST)
Date: Tue, 12 Feb 2013 16:19:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel
 booting
Message-Id: <20130212161912.6a9e9293.akpm@linux-foundation.org>
In-Reply-To: <CA+8MBb+3_xWv1wMWv0+gwWm9exPCNTZWG3mXQnBsUbc5fJnuiA@mail.gmail.com>
References: <51074786.5030007@huawei.com>
	<1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
	<51131248.3080203@huawei.com>
	<5113450C.1080109@huawei.com>
	<CA+8MBb+3_xWv1wMWv0+gwWm9exPCNTZWG3mXQnBsUbc5fJnuiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Matt Fleming <matt.fleming@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

On Tue, 12 Feb 2013 16:11:33 -0800
Tony Luck <tony.luck@gmail.com> wrote:

> Building linux-next today (tag next-20130212) I get the following errors when
> building arch/ia64/configs/{tiger_defconfig, zx1_defconfig, bigsur_defconfig,
> sim_defconfig}
> 
> arch/ia64/mm/init.c: In function 'free_initrd_mem':
> arch/ia64/mm/init.c:215: error: 'max_addr' undeclared (first use in
> this function)
> arch/ia64/mm/init.c:215: error: (Each undeclared identifier is
> reported only once
> arch/ia64/mm/init.c:215: error: for each function it appears in.)
> arch/ia64/mm/init.c:216: error: implicit declaration of function
> 'GRANULEROUNDDOWN'
> 
> with "git blame" saying that these lines in init.c were added/changed by
> 
> commit 5a54b4fb8f554b15c6113e30ca8412b7fe11c62e
> Author: Xishi Qiu <qiuxishi@huawei.com>
> Date:   Thu Feb 7 12:25:59 2013 +1100
> 
>     ia64/mm: fix a bad_page bug when crash kernel booting
> 

Presumably this:

--- a/arch/ia64/mm/init.c~ia64-mm-fix-a-bad_page-bug-when-crash-kernel-booting-fix
+++ a/arch/ia64/mm/init.c
@@ -27,6 +27,7 @@
 #include <asm/machvec.h>
 #include <asm/numa.h>
 #include <asm/patch.h>
+#include <asm/meminit.h>
 #include <asm/pgalloc.h>
 #include <asm/sal.h>
 #include <asm/sections.h>
_


But, umm, why am I sitting here trying to maintain an ia64 bugfix and
handling bug reports from the ia64 maintainer?  Wanna swap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
