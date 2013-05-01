Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 4FC466B01F8
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:36:58 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 16:36:56 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 0517019D803E
	for <linux-mm@kvack.org>; Wed,  1 May 2013 16:36:45 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41Maocw372050
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:36:50 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MaodA018458
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:36:50 -0600
Message-ID: <51819900.1010301@linux.vnet.ibm.com>
Date: Wed, 01 May 2013 15:36:48 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mmzone: note that node_size_lock should be manipulated
 via pgdat_resize_lock()
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-4-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011528550.8804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1305011528550.8804@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2013 03:29 PM, David Rientjes wrote:
> On Wed, 1 May 2013, Cody P Schafer wrote:
>
>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>
> Nack, pgdat_resize_unlock() is unnecessary if irqs are known to be
> disabled.
>

All this patch does is is indicate that rather than using node_size_lock 
directly (as it won't be around without CONFIG_MEMORY_HOTPLUG), one 
should use the pgdat_resize_[un]lock() helper macros.

And yes, _strictly_ speaking, one could want to avoid the 
spin_lock_irqsave/restore that pgdat_resize_*lock() does.

Right now we don't provide helpers that do that. Do you see a need for them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
