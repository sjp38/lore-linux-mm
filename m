Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 869346B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 16:31:43 -0500 (EST)
Date: Thu, 21 Feb 2013 13:31:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: let /proc/meminfo report physical memory
 installed as "MemTotal"
Message-Id: <20130221133141.73855348.akpm@linux-foundation.org>
In-Reply-To: <512658AA.5060806@gmail.com>
References: <alpine.DEB.2.02.1302191326150.6322@chino.kir.corp.google.com>
	<1361381245-14664-1-git-send-email-jiang.liu@huawei.com>
	<20130220144917.7d289ef0.akpm@linux-foundation.org>
	<512658AA.5060806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: David Rientjes <rientjes@google.com>, sworddragon2@aol.com, Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Fri, 22 Feb 2013 01:26:02 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> 	It's really hard, but I think it deserve it because have reduced
> about 460 lines of code when fixing this bug. So how about following
> patchset?
> 	The first 27 patches introduces some help functions to simplify
> free_initmem() and free_initrd_mem() for most arches.
> 	The 28th patch increases zone->managed_pages when freeing reserved
> pages.
> 	The 29th patch change /sys/.../nodex/meminfo to report "available
> pages within the node" as MemTatoal.

yikes.

Let's defer the problem for now.  Please send the patches out in the
usual fashion after 3.9-rc1 and we'll take a look?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
