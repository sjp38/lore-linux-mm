Received: by wf-out-1314.google.com with SMTP id 28so565728wfc.11
        for <linux-mm@kvack.org>; Fri, 19 Sep 2008 08:23:10 -0700 (PDT)
Message-ID: <2f11576a0809190823t233c6f57m48bd9724a85234a6@mail.gmail.com>
Date: Sat, 20 Sep 2008 00:23:10 +0900
From: "KOSAKI Motohiro" <m-kosaki@ceres.dti.ne.jp>
Subject: Re: [patch 3/4] cpu alloc: The allocator
In-Reply-To: <20080919145929.158651064@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080919145859.062069850@quilx.com>
	 <20080919145929.158651064@quilx.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

> +/*
> + * Allocate an object of a certain size
> + *
> + * Returns a special pointer that can be used with CPU_PTR to find the
> + * address of the object for a certain cpu.
> + */
> +void *cpu_alloc(unsigned long size, gfp_t gfpflags, unsigned long align)

cpu_alloc is good name?
I think some person suspect cpu-hotplug related function.

per_cpu_alloc() or cpu_mem_alloc() are wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
