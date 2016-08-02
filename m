Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 080B86B0262
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:27:11 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q62so365925993oih.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:27:11 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0158.hostedemail.com. [216.40.44.158])
        by mx.google.com with ESMTPS id w63si17700608itg.10.2016.08.02.06.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 06:27:10 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:27:02 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1082/1285] Replace numeric parameter like 0444 with
 macro
Message-ID: <20160802092702.147e4e57@gandalf.local.home>
In-Reply-To: <20160802121448.22258-1-baolex.ni@intel.com>
References: <20160802121448.22258-1-baolex.ni@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baole Ni <baolex.ni@intel.com>
Cc: sjenning@redhat.com, jiangshanlai@gmail.com, mathieu.desnoyers@efficios.com, m.chehab@samsung.com, gregkh@linuxfoundation.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, chuansheng.liu@intel.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com

On Tue,  2 Aug 2016 20:14:48 +0800
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
>  mm/zswap.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 275b22c..aede3ee 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -78,7 +78,7 @@ static u64 zswap_duplicate_entry;
>  
>  /* Enable/disable zswap (disabled by default) */
>  static bool zswap_enabled;
> -module_param_named(enabled, zswap_enabled, bool, 0644);
> +module_param_named(enabled, zswap_enabled, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
>  
>  /* Crypto compressor to use */
>  #define ZSWAP_COMPRESSOR_DEFAULT "lzo"
> @@ -91,7 +91,7 @@ static struct kernel_param_ops zswap_compressor_param_ops = {
>  	.free =		param_free_charp,
>  };
>  module_param_cb(compressor, &zswap_compressor_param_ops,
> -		&zswap_compressor, 0644);
> +		&zswap_compressor, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
>  
>  /* Compressed storage zpool to use */
>  #define ZSWAP_ZPOOL_DEFAULT "zbud"
> @@ -102,11 +102,11 @@ static struct kernel_param_ops zswap_zpool_param_ops = {
>  	.get =		param_get_charp,
>  	.free =		param_free_charp,
>  };
> -module_param_cb(zpool, &zswap_zpool_param_ops, &zswap_zpool_type, 0644);
> +module_param_cb(zpool, &zswap_zpool_param_ops, &zswap_zpool_type, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
>  
>  /* The maximum percentage of memory that the compressed pool can occupy */
>  static unsigned int zswap_max_pool_percent = 20;
> -module_param_named(max_pool_percent, zswap_max_pool_percent, uint, 0644);
> +module_param_named(max_pool_percent, zswap_max_pool_percent, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
>  
>  /*********************************
>  * data structures

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
