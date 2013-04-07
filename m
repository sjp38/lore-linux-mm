Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5C5EE6B0006
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 11:41:44 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id jz10so4638316veb.19
        for <linux-mm@kvack.org>; Sun, 07 Apr 2013 08:41:43 -0700 (PDT)
Message-ID: <516193BC.3000503@gmail.com>
Date: Sun, 07 Apr 2013 11:41:48 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: when handling percpu_pagelist_fraction, use on_each_cpu()
 to set percpu pageset fields.
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com> <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-4-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kosaki.motohiro@gmail.com

(4/5/13 4:33 PM), Cody P Schafer wrote:
> In free_hot_cold_page(), we rely on pcp->batch remaining stable.
> Updating it without being on the cpu owning the percpu pageset
> potentially destroys this stability.
> 
> Change for_each_cpu() to on_each_cpu() to fix.
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
