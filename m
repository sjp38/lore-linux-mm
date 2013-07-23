Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 0E3376B0034
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 15:16:01 -0400 (EDT)
Received: by mail-ye0-f178.google.com with SMTP id m15so2617113yen.37
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:16:01 -0700 (PDT)
Date: Tue, 23 Jul 2013 15:15:55 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 04/21] acpi: Remove "continue" in macro INVALID_TABLE().
Message-ID: <20130723191555.GJ21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-5-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-5-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:17PM +0800, Tang Chen wrote:
> The macro INVALID_TABLE() is defined like this:
> 
>  #define INVALID_TABLE(x, path, name)                                    \
>          { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); continue; }
> 
> And it is used like this:
> 
> 	for (...) {
> 		...
> 		if (...)
> 			INVALID_TABLE()
> 		...
> 	}
> 
> The "continue" in the macro makes the code hard to understand.
> Change it to the style like other macros:
> 
>  #define INVALID_TABLE(x, path, name)                                    \
>          do { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); } while (0)
> 
> So after this patch, this macro should be used like this:
> 
> 	for (...) {
> 		...
> 		if (...) {
> 			INVALID_TABLE()
> 			continue;
> 		}
> 		...
> 	}
> 
> Add the "continue" wherever the macro is called.
> (For now, it is only called in acpi_initrd_override().)
> 
> The idea is from Yinghai Lu <yinghai@kernel.org>.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
