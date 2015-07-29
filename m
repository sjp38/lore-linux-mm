Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 31EB66B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:08:54 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so23250747wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 05:08:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a17si5446305wiv.61.2015.07.29.05.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 05:08:52 -0700 (PDT)
Date: Wed, 29 Jul 2015 08:07:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Message-ID: <20150729120738.GA10001@cmpxchg.org>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de>
 <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
 <20150720175538.GJ2561@suse.de>
 <05af01d0c47f$3337ccd0$99a76670$@samsung.com>
 <20150722140530.GK2561@suse.de>
 <030e01d0c9bd$20e1df60$62a59e20$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <030e01d0c9bd$20e1df60$62a59e20$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: 'Mel Gorman' <mgorman@suse.de>, akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

On Wed, Jul 29, 2015 at 10:41:10AM +0530, PINTU KUMAR wrote:
> I was talking about only the following case.
> Instead of hard coding the hibernation_mode in shrink_all_memory, 
> We can set it at runtime.
> 
> -               .hibernation_mode = 1,
> 
> +       if (system_entering_hibernation())
> +               sc.hibernation_mode = 1;
> +       else
> +               sc.hibernation_mode = 0;

Nobody outside hibernation uses this function (and likely never will).
The hardcoding is fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
