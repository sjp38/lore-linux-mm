Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B6A2F6B6DA8
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 02:48:09 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s71so13285182pfi.22
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 23:48:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d125si14291996pgc.418.2018.12.03.23.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 23:48:08 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB47iNCl098814
	for <linux-mm@kvack.org>; Tue, 4 Dec 2018 02:48:08 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p5k34x5h4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Dec 2018 02:48:07 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 4 Dec 2018 07:48:05 -0000
Date: Tue, 4 Dec 2018 09:47:58 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 1/3] mm: add include files so that function definitions
 have a prototype
References: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <466ad4ebe5d788e7be6a14fbbcaaa9596bac7141.1543899764.git.dato@net.com.org.es>
Message-Id: <20181204074757.GF26700@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adeodato =?iso-8859-1?Q?Sim=F3?= <dato@net.com.org.es>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On Tue, Dec 04, 2018 at 02:14:22AM -0300, Adeodato Sim� wrote:
> Previously, rodata_test(), usercopy_warn(), and usercopy_abort() were
> defined without a matching prototype. Detected by -Wmissing-prototypes
> GCC flag.
> 
> Signed-off-by: Adeodato Sim� <dato@net.com.org.es>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
> I started poking at this after kernel-janitors got the suggestion[1]
> to look into the -Wmissing-prototypes warnings.
> 
> Thanks for considering!
> 
> [1]: https://www.spinics.net/lists/linux-kernel-janitors/msg43981.html
> 
>  mm/rodata_test.c | 1 +
>  mm/usercopy.c    | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/mm/rodata_test.c b/mm/rodata_test.c
> index d908c8769b48..01306defbd1b 100644
> --- a/mm/rodata_test.c
> +++ b/mm/rodata_test.c
> @@ -11,6 +11,7 @@
>   */
>  #define pr_fmt(fmt) "rodata_test: " fmt
> 
> +#include <linux/rodata_test.h>
>  #include <linux/uaccess.h>
>  #include <asm/sections.h>
> 
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 852eb4e53f06..f487ba4888df 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -20,6 +20,7 @@
>  #include <linux/sched/task.h>
>  #include <linux/sched/task_stack.h>
>  #include <linux/thread_info.h>
> +#include <linux/uaccess.h>
>  #include <linux/atomic.h>
>  #include <linux/jump_label.h>
>  #include <asm/sections.h>
> -- 
> 2.19.2
> 

-- 
Sincerely yours,
Mike.
