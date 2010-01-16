Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B4666B006A
	for <linux-mm@kvack.org>; Fri, 15 Jan 2010 20:08:50 -0500 (EST)
From: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Date: Sat, 16 Jan 2010 09:08:41 +0800
Subject: RE: [PATCH-RESEND v4] memory-hotplug: create /sys/firmware/memmap
 entry for new memory
Message-ID: <DA586906BA1FFC4384FCFD6429ECE86034FF85EB@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560F92@shzsmsx502.ccr.corp.intel.com>
 <20100115143812.b70161d2.akpm@linux-foundation.org>
In-Reply-To: <20100115143812.b70161d2.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

It is very strange issue since I already test it before sending it out, I w=
ill retry it in local.

Thanks & Regards,
Shaohui


-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Saturday, January 16, 2010 6:38 AM
To: Zheng, Shaohui
Cc: linux-mm@kvack.org; linux-kernel@vger.kernel.org; ak@linux.intel.com; y=
-goto@jp.fujitsu.com; Dave Hansen; Wu, Fengguang; x86@kernel.org
Subject: Re: [PATCH-RESEND v4] memory-hotplug: create /sys/firmware/memmap =
entry for new memory

On Mon, 11 Jan 2010 10:00:11 +0800
"Zheng, Shaohui" <shaohui.zheng@intel.com> wrote:

> memory-hotplug: create /sys/firmware/memmap entry for hot-added memory
>=20
> Interface firmware_map_add was not called in explict, Remove it and add f=
unction
> firmware_map_add_hotplug as hotplug interface of memmap.
>=20
> When we hot-add new memory, sysfs does not export memmap entry for it. we=
 add
>  a call in function add_memory to function firmware_map_add_hotplug.
>=20
> Add a new function add_sysfs_fw_map_entry to create memmap entry, it can =
avoid=20
> duplicated codes.

The patch causes an early exception in kmem_cache_alloc_notrace() -
probably due to a null cache pointer.

config: http://master.kernel.org/~akpm/config-akpm2.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
