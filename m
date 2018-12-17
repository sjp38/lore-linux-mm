Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70B8E8E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 18:07:30 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 202so11955326pgb.6
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 15:07:30 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z14si9846202pga.349.2018.12.17.15.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 15:07:29 -0800 (PST)
Date: Mon, 17 Dec 2018 15:07:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for
 HugePages
Message-Id: <20181217150726.6eea4942005516d565dae488@linux-foundation.org>
In-Reply-To: <20181217225113.17864-1-osalvador@suse.de>
References: <20181217225113.17864-1-osalvador@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: mhocko@suse.com, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Dec 2018 23:51:13 +0100 Oscar Salvador <osalvador@suse.de> wrote:

> v1 -> v2:
> 	- Fix the logic for skipping pages by Michal
> 
> ---

Please be careful with the "^---$".  It signifies end-of-changelog, so
I ended up without a changelog!

> >From e346b151037d3c37feb10a981a4d2a25018acf81 Mon Sep 17 00:00:00 2001
> From: Oscar Salvador <osalvador@suse.de>
> Date: Mon, 17 Dec 2018 14:53:35 +0100
> Subject: [PATCH] mm, page_alloc: Fix has_unmovable_pages for HugePages
> 
> While playing with gigantic hugepages and memory_hotplug, I triggered
> the following #PF when "cat memoryX/removable":
> 
> ...
>
> Also, since gigantic pages span several pageblocks, re-adjust the logic
> for skipping pages.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

cc:stable?
