Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE1626B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:26:57 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e139so363217341oib.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:26:57 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0193.hostedemail.com. [216.40.44.193])
        by mx.google.com with ESMTPS id d77si3215513ioj.122.2016.08.02.06.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 06:26:56 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:26:52 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1081/1285] Replace numeric parameter like 0444 with
 macro
Message-ID: <20160802092652.52b7c58f@gandalf.local.home>
In-Reply-To: <20160802121443.22191-1-baolex.ni@intel.com>
References: <20160802121443.22191-1-baolex.ni@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baole Ni <baolex.ni@intel.com>
Cc: jbaron@akamai.com, jiangshanlai@gmail.com, mathieu.desnoyers@efficios.com, m.chehab@samsung.com, gregkh@linuxfoundation.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, chuansheng.liu@intel.com

On Tue,  2 Aug 2016 20:14:43 +0800
Baole Ni <baolex.ni@intel.com> wrote:

> I find that the developers often just specified the numeric value
> when calling a macro which is defined with a parameter for access permission.
> As we know, these numeric value for access permission have had the corresponding macro,
> and that using macro can improve the robustness and readability of the code,
> thus, I suggest replacing the numeric parameter with the macro.
> 

NACK!

I find 0444 more readable than S_IRUSR | S_IRGRP | S_IROTH.

-- Steve

> Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
> Signed-off-by: Baole Ni <baolex.ni@intel.com>
> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index de2c176..fad009c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -67,7 +67,7 @@ int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
>  #endif
>  
>  static bool ignore_rlimit_data;
> -core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
> +core_param(ignore_rlimit_data, ignore_rlimit_data, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
>  
>  static void unmap_region(struct mm_struct *mm,
>  		struct vm_area_struct *vma, struct vm_area_struct *prev,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
