Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 23F726B0200
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:42:46 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq12so2681pab.26
        for <linux-mm@kvack.org>; Wed, 01 May 2013 15:42:45 -0700 (PDT)
Date: Wed, 1 May 2013 15:42:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] mmzone: note that node_size_lock should be manipulated
 via pgdat_resize_lock()
In-Reply-To: <51819900.1010301@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1305011541260.8804@chino.kir.corp.google.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-4-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011528550.8804@chino.kir.corp.google.com> <51819900.1010301@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 May 2013, Cody P Schafer wrote:

> > > Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> > 
> > Nack, pgdat_resize_unlock() is unnecessary if irqs are known to be
> > disabled.
> > 
> 
> All this patch does is is indicate that rather than using node_size_lock
> directly (as it won't be around without CONFIG_MEMORY_HOTPLUG), one should use
> the pgdat_resize_[un]lock() helper macros.
> 

I think that's obvious given the lock is surrounded by
#ifdef CONFIG_MEMORY_HOTPLUG.  The fact remains that hotplug code need not 
use pgdat_resize_lock() if irqs are disabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
