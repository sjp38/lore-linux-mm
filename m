Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3BF8828E1
	for <linux-mm@kvack.org>; Mon, 16 May 2016 03:31:47 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so55095911lbc.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:31:47 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 142si18528342wmn.98.2016.05.16.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 00:31:46 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id e201so16041465wme.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:31:46 -0700 (PDT)
Date: Mon, 16 May 2016 09:31:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: unhide vmstat_text definition for CONFIG_SMP
Message-ID: <20160516073144.GA23146@dhcp22.suse.cz>
References: <1462978517-2972312-1-git-send-email-arnd@arndb.de>
 <alpine.DEB.2.20.1605111011260.9351@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1605111011260.9351@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 11-05-16 10:32:11, Christoph Lameter wrote:
> Subject: Do not build vmstat_refresh if there is no procfs support
> 
> It makes no sense to build functionality into the kernel that
> cannot be used and causes build issues.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/vmstat.c
> ===================================================================
> --- linux.orig/mm/vmstat.c
> +++ linux/mm/vmstat.c
> @@ -1358,7 +1358,6 @@ static const struct file_operations proc
>  	.llseek		= seq_lseek,
>  	.release	= seq_release,
>  };
> -#endif /* CONFIG_PROC_FS */
> 
>  #ifdef CONFIG_SMP
>  static struct workqueue_struct *vmstat_wq;

This doesn't work because it makes the whole vmstat_wq depend on
CONFIG_PROC_FS. Which is obviously bad because we both rely on doing the
periodic sync even when counters are not exported to the userspace and
it wound't compile anyway...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
