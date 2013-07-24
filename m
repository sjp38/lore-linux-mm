Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 052CE6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:55:52 -0400 (EDT)
Received: by mail-ye0-f173.google.com with SMTP id m7so2949207yen.32
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 08:55:52 -0700 (PDT)
Date: Wed, 24 Jul 2013 11:55:46 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 13/21] x86, acpi: Try to find SRAT in firmware earlier.
Message-ID: <20130724155546.GB20377@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-14-git-send-email-tangchen@cn.fujitsu.com>
 <20130723204949.GR21100@mtj.dyndns.org>
 <51EFA873.9050300@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EFA873.9050300@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, Jul 24, 2013 at 06:12:03PM +0800, Tang Chen wrote:
> Do you mean get the SRAT's address without touching any ACPI global
> variables, such as acpi_gbl_root_table_list ?
> 
> The physical addresses of all tables is stored in RSDT (Root System
> Description Table), which is the root table. We need to parse RSDT
> to get SRAT address.
> 
> Using acpi_gbl_root_table_list is very convenient. The initialization
> of acpi_gbl_root_table_list is using acpi_os_map_memory(), so it can be
> done before init_mem_mapping() and relocate_initrd().
> 
> With acpi_gbl_root_table_list initialized, we can iterate it and find
> SRAT easily. Otherwise, we have to do the same procedure to parse RSDT,
> and find SRAT, which I don't think could be any simpler. I think reuse
> the existing acpi_gbl_root_table_list code is better.

I see.  As long as ACPI people are fine with the modifications, I
don't mind either way.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
