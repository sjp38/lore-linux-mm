Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id BA6DD6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 15:56:11 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id z20so1318081yhz.34
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 12:56:10 -0700 (PDT)
Date: Tue, 23 Jul 2013 15:56:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 09/21] x86: Make get_ramdisk_{image|size}() global.
Message-ID: <20130723195604.GN21100@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-10-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374220774-29974-10-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Fri, Jul 19, 2013 at 03:59:22PM +0800, Tang Chen wrote:
> In the following patches, we need to call get_ramdisk_{image|size}()
> to get initrd file's address and size. So make these two functions
> global.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  arch/x86/include/asm/setup.h |    3 +++
>  arch/x86/kernel/setup.c      |    4 ++--
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/setup.h b/arch/x86/include/asm/setup.h
> index b7bf350..69de7a1 100644
> --- a/arch/x86/include/asm/setup.h
> +++ b/arch/x86/include/asm/setup.h
> @@ -106,6 +106,9 @@ void *extend_brk(size_t size, size_t align);
>  	RESERVE_BRK(name, sizeof(type) * entries)
>  
>  extern void probe_roms(void);
> +u64 get_ramdisk_image(void);
> +u64 get_ramdisk_size(void);

Might as well make these accessors inline functions.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
