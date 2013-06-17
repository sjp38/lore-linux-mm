Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5F06A6B0034
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 17:06:47 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id f14so1747784qak.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 14:06:46 -0700 (PDT)
Date: Mon, 17 Jun 2013 14:06:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 04/22] x86, ACPI: Search buffer above 4GB in a
 second try for acpi initrd table override
Message-ID: <20130617210636.GO32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-5-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-acpi@vger.kernel.org

On Thu, Jun 13, 2013 at 09:02:51PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> Now we only search buffer for new acpi tables in initrd under
> 4GB. In some case, like user use memmap to exclude all low ram,
> we may not find range for it under 4GB. So do second try to
> search for buffer above 4GB.
> 
> Since later accessing to the tables is using early_ioremap(),

Maybe "later accesses to the tables" would read better?

> using memory above 4GB is OK.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
> Cc: linux-acpi@vger.kernel.org
> Tested-by: Thomas Renninger <trenn@suse.de>
> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> Tested-by: Tang Chen <tangchen@cn.fujitsu.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
