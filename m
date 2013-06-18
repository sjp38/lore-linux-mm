Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 82B0F6B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 20:33:17 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id c41so1307026yho.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:33:16 -0700 (PDT)
Date: Mon, 17 Jun 2013 17:33:08 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 09/22] x86, ACPI: Find acpi tables in initrd
 early from head_32.S/head64.c
Message-ID: <20130618003308.GS32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-10-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-10-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Jacob Shin <jacob.shin@amd.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

On Thu, Jun 13, 2013 at 09:02:56PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>

Ditto for the opening.  Probably not a must, I suppose, but would be
very nice.

> head64.c could use #PF handler setup page table to access initrd before
> init mem mapping and initrd relocating.
> 
> head_32.S could use 32bit flat mode to access initrd before init mem
> mapping initrd relocating.
> 
> This patch introduces x86_acpi_override_find(), which is called from
> head_32.S/head64.c, to replace acpi_initrd_override_find(). So that we
> can makes 32bit and 64 bit more consistent.
> 
> -v2: use inline function in header file instead according to tj.
>      also still need to keep #idef head_32.S to avoid compiling error.
> -v3: need to move down reserve_initrd() after acpi_initrd_override_copy(),
>      to make sure we are using right address.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Jacob Shin <jacob.shin@amd.com>
> Cc: Rafael J. Wysocki <rjw@sisk.pl>
> Cc: linux-acpi@vger.kernel.org
> Tested-by: Thomas Renninger <trenn@suse.de>
> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> Tested-by: Tang Chen <tangchen@cn.fujitsu.com>

Other than that,

 Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
