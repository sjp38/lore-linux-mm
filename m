Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 71E076B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 09:58:54 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH part2 0/4] acpi: Trivial fix and improving for memory hotplug.
Date: Thu, 08 Aug 2013 16:09:10 +0200
Message-ID: <1851799.n4moZnvj4u@vostro.rjw.lan>
In-Reply-To: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thursday, August 08, 2013 01:03:55 PM Tang Chen wrote:
> This patch-set does some trivial fix and improving in ACPI code
> for memory hotplug.
> 
> Patch 1,3,4 have been acked.
> 
> Tang Chen (4):
>   acpi: Print Hot-Pluggable Field in SRAT.
>   earlycpio.c: Fix the confusing comment of find_cpio_data().
>   acpi: Remove "continue" in macro INVALID_TABLE().
>   acpi: Introduce acpi_verify_initrd() to check if a table is invalid.
> 
>  arch/x86/mm/srat.c |   11 ++++--
>  drivers/acpi/osl.c |   84 +++++++++++++++++++++++++++++++++++++++------------
>  lib/earlycpio.c    |   27 ++++++++--------
>  3 files changed, 85 insertions(+), 37 deletions(-)

It looks like this part doesn't depend on the other parts, is that correct?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
