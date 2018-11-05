Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE316B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 15:51:55 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y185-v6so7729419wmg.6
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 12:51:55 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id u9-v6si35744701wrd.317.2018.11.05.12.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Nov 2018 12:51:53 -0800 (PST)
Subject: Re: [RFC PATCH v4 02/13] ktask: multithread CPU-intensive kernel work
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-3-daniel.m.jordan@oracle.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <736b23a4-cb32-7926-101a-9b6555e59b5e@infradead.org>
Date: Mon, 5 Nov 2018 12:51:33 -0800
MIME-Version: 1.0
In-Reply-To: <20181105165558.11698-3-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On 11/5/18 8:55 AM, Daniel Jordan wrote:
> diff --git a/init/Kconfig b/init/Kconfig
> index 41583f468cb4..ed82f76ed0b7 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -346,6 +346,17 @@ config AUDIT_TREE
>  	depends on AUDITSYSCALL
>  	select FSNOTIFY
>  
> +config KTASK
> +	bool "Multithread CPU-intensive kernel work"
> +	depends on SMP
> +	default y
> +	help
> +	  Parallelize CPU-intensive kernel work.  This feature is designed for
> +          big machines that can take advantage of their extra CPUs to speed up
> +	  large kernel tasks.  When enabled, kworker threads may occupy more
> +          CPU time during these kernel tasks, but these threads are throttled
> +          when other tasks on the system need CPU time.

Use tab + 2 spaces consistently for help text indentation, please.

> +
>  source "kernel/irq/Kconfig"
>  source "kernel/time/Kconfig"
>  source "kernel/Kconfig.preempt"


-- 
~Randy
