Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id E4DAB6B01AE
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:26:39 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v14so1025555pde.32
        for <linux-mm@kvack.org>; Wed, 01 May 2013 15:26:39 -0700 (PDT)
Date: Wed, 1 May 2013 15:26:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mmzone: make holding lock_memory_hotplug() a
 requirement for updating pgdat size
In-Reply-To: <1367446635-12856-2-git-send-email-cody@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1305011525580.8804@chino.kir.corp.google.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-2-git-send-email-cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 May 2013, Cody P Schafer wrote:

> All updaters of pgdat size (spanned_pages, start_pfn, and
> present_pages) currently also hold lock_memory_hotplug() (in addition
> to pgdat_resize_lock()).
> 
> Document this and make holding of that lock a requirement on the update
> side for now, but keep the pgdat_resize_lock() around for readers that
> can't lock a mutex.
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>

Nack, these fields are initialized at boot without lock_memory_hotplug(), 
so you're statement is wrong, and all you need is pgdat_resize_lock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
