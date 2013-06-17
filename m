Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 159876B0037
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:38:36 -0400 (EDT)
Received: by mail-yh0-f52.google.com with SMTP id f10so1251701yha.25
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 16:38:35 -0700 (PDT)
Date: Mon, 17 Jun 2013 16:38:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 07/22] x86, ACPI: Store override acpi tables
 phys addr in cpio files info array
Message-ID: <20130617233827.GP32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-8-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-8-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

On Thu, Jun 13, 2013 at 09:02:54PM +0800, Tang Chen wrote:
> -static struct cpio_data __initdata acpi_initrd_files[ACPI_OVERRIDE_TABLES];
> +struct file_pos {
> +	phys_addr_t data;
> +	phys_addr_t size;
> +};

Isn't file_pos too generic as name?  Would acpi_initrd_file_pos too
long?  Maybe just struct acpi_initrd_file?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
