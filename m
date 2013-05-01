Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0494D6B01FB
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:39:35 -0400 (EDT)
Received: by mail-da0-f48.google.com with SMTP id h32so1920dak.21
        for <linux-mm@kvack.org>; Wed, 01 May 2013 15:39:35 -0700 (PDT)
Date: Wed, 1 May 2013 15:39:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mmzone: make holding lock_memory_hotplug() a
 requirement for updating pgdat size
In-Reply-To: <518197E2.7050004@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1305011539010.8804@chino.kir.corp.google.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-2-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011525580.8804@chino.kir.corp.google.com> <518197E2.7050004@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 1 May 2013, Cody P Schafer wrote:

> They are also initialized at boot without pgdat_resize_lock(), if we consider
> boot time, quite a few of the statements on when locking is required are
> wrong.
> 
> That said, you are correct that it is not strictly required to hold
> lock_memory_hotplug() when updating the fields in question because
> pgdat_resize_lock() is used.
> 

I think you've confused node size fields with zone size fields.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
