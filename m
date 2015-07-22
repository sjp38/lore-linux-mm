Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 30DEF9003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:05:45 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so165200509wib.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:05:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jg6si3844443wid.4.2015.07.22.07.05.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 07:05:43 -0700 (PDT)
Date: Wed, 22 Jul 2015 15:05:30 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Message-ID: <20150722140530.GK2561@suse.de>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de>
 <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
 <20150720175538.GJ2561@suse.de>
 <05af01d0c47f$3337ccd0$99a76670$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <05af01d0c47f$3337ccd0$99a76670$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

On Wed, Jul 22, 2015 at 06:33:26PM +0530, PINTU KUMAR wrote:
> Dear Mel, thank you very much for your comments and suggestions.
> I will drop this one and look on further improving direct_reclaim and
> compaction.
> Just few more comments below before I close.
> 
> Also, during this patch, I feel that the hibernation_mode part in
> shrink_all_memory can be corrected.
> So, can I separately submit the below patch?
> That is instead of hard-coding the hibernation_mode, we can get hibernation
> status using:
> system_entering_hibernation()
> 
> Please let me know your suggestion about this changes.
> 
> -#ifdef CONFIG_HIBERNATION
> +#if defined CONFIG_HIBERNATION || CONFIG_SHRINK_MEMORY

This appears to be a patch on top of "Add /proc/sys/vm/shrink_memory
feature" so I do not see what would be separately submitted that would
make sense.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
