Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0836B0070
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 02:53:05 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so89652041pdb.1
        for <linux-mm@kvack.org>; Sun, 28 Jun 2015 23:53:04 -0700 (PDT)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id qm10si62972049pdb.138.2015.06.28.23.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jun 2015 23:53:04 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 64226AC037F
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 15:52:59 +0900 (JST)
Message-ID: <5590EAA9.5090104@jp.fujitsu.com>
Date: Mon, 29 Jun 2015 15:50:17 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 1/8] mm: add a new config to manage the code
References: <558E084A.60900@huawei.com> <558E0913.7020501@huawei.com>
In-Reply-To: <558E0913.7020501@huawei.com>
Content-Type: multipart/mixed;
 boundary="------------030208070301040603070806"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------030208070301040603070806
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 2015/06/27 11:23, Xishi Qiu wrote:
> This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", set it
                                              CONFIG_MEMORY_MIRROR
> off by default.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   mm/Kconfig | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 390214d..c40bb8b 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
>   	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>   	depends on MIGRATION
>
> +config MEMORY_MIRROR

   In following patches, you use CONFIG_MEMORY_MIRROR.

I think the name is too generic besides it's depends on ACPI.
But I'm not sure address based memory mirror is planned in other platform.

So, hmm. How about dividing the config into 2 parts like attached ? (just an example)

Thanks,
-Kame

--------------030208070301040603070806
Content-Type: text/plain; charset=Shift_JIS;
 name="0001-add-a-new-config-option-for-memory-mirror.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-add-a-new-config-option-for-memory-mirror.patch"


--------------030208070301040603070806--
