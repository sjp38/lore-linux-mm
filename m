Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 547E66B002E
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:55:17 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id s18so1642906wrg.5
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 02:55:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b9si6111942wri.547.2018.02.15.02.55.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 02:55:15 -0800 (PST)
Date: Thu, 15 Feb 2018 10:55:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 1/1] mm: initialize pages on demand during boot
Message-ID: <20180215105510.5md37yoqij2f663k@suse.de>
References: <20180214163343.21234-1-pasha.tatashin@oracle.com>
 <20180214163343.21234-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20180214163343.21234-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 14, 2018 at 11:33:43AM -0500, Pavel Tatashin wrote:
> Deferred page initialization allows the boot cpu to initialize a small
> subset of the system's pages early in boot, with other cpus doing the rest
> later on.
> 

Bit late to the game but

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
