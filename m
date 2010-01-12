Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 137C06B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 03:58:33 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Tue, 12 Jan 2010 16:57:40 +0800
Subject: RE: [ RESEND PATCH v3] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860316C01D6@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE860316C0133@shzsmsx502.ccr.corp.intel.com>
 <20100112170433.394be31b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112170433.394be31b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>


3 points...
1. I think this patch cannot be compiled in archs other than x86. Right ?
   IOW, please add static inline dummy...
[Zheng, Shaohui] Agree, I will add a static dummy function

2. pgdat->[start,end], totalram_pages etc...are updated at memory hotplug.
   Please place the hook nearby them.
[Zheng, Shaohui] Agree.

3. I recommend you yo use memory hotplug notifier.
   If it's allowed, it will be cleaner.
   It seems there are no strict ordering to update parameters this patch to=
uches.

[Zheng, Shaohui] Kame, do you means put the hook into function slab_mem_goi=
ng_online_callback, it seems a good idea. If we select this method, we will=
 need not to update these variable in function add_memory explicitly.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
