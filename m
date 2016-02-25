Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 20F9D6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 03:29:15 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fl4so28486572pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 00:29:15 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id lf12si10951451pab.207.2016.02.25.00.29.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 00:29:14 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id q63so29022036pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 00:29:14 -0800 (PST)
Date: Thu, 25 Feb 2016 00:29:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, memory hotplug: print debug message in the proper
 way for online_pages
In-Reply-To: <1456386319-9050-1-git-send-email-slaoub@gmail.com>
Message-ID: <alpine.DEB.2.10.1602250028290.17685@chino.kir.corp.google.com>
References: <1456386319-9050-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Feb 2016, Chen Yucong wrote:

> online_pages() simply returns an error value if
> memory_notify(MEM_GOING_ONLINE, &arg) return a value that is not
> what we want for successfully onlining target pages. This patch
> arms to print more failure information like offline_pages() in
> online_pages.
> 
> This patch also converts printk(KERN_<LEVEL>) to pr_<level>(),
> and moves __offline_pages() to not print failure information with
> KERN_INFO according to David Rientjes's suggestion[1].
> 
> [1] https://lkml.org/lkml/2016/2/24/1094
> 
> Signed-off-by: Chen Yucong <slaoub@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

Cool!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
