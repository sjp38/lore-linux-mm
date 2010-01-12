Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F1B56B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 00:46:53 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Tue, 12 Jan 2010 13:45:02 +0800
Subject: RE: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel(v1)
Message-ID: <DA586906BA1FFC4384FCFD6429ECE860316C0011@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
	<20100108124851.GB6153@localhost>
	<DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
	<20100111124303.GA21408@localhost>
 <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>


Hmmm....could you rewrite /dev/mem to use kernel/resource.c other than
modifing e820 maps. ?
Two reasons.
  - e820map is considerted to be stable, read-only after boot.
  - We don't need to add more x86 special codes.
[Zheng, Shaohui] Kame, when I write this patch, I also feel confused whethe=
r update e820map. Because of the dependency in function page_is_ram, so we =
still update it in my patch.
I see that Fengguang already draft patches to change function page_is_ram, =
the new page_is_ram function use kernel/resource.c instead. That is great t=
hat we can still keep a stable e820map. I will resend the patch which updat=
e variable high_memory, max_low_pfn and max_pfn only.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
