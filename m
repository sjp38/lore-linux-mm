Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 1C6826B01F6
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:32:12 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 16:32:11 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1E88019D8048
	for <linux-mm@kvack.org>; Wed,  1 May 2013 16:32:02 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41MW7Hc108744
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:32:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MW7Of018385
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:32:07 -0600
Message-ID: <518197E2.7050004@linux.vnet.ibm.com>
Date: Wed, 01 May 2013 15:32:02 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mmzone: make holding lock_memory_hotplug() a requirement
 for updating pgdat size
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-2-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011525580.8804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1305011525580.8804@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2013 03:26 PM, David Rientjes wrote:
> On Wed, 1 May 2013, Cody P Schafer wrote:
>
>> All updaters of pgdat size (spanned_pages, start_pfn, and
>> present_pages) currently also hold lock_memory_hotplug() (in addition
>> to pgdat_resize_lock()).
>>
>> Document this and make holding of that lock a requirement on the update
>> side for now, but keep the pgdat_resize_lock() around for readers that
>> can't lock a mutex.
>>
>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>
> Nack, these fields are initialized at boot without lock_memory_hotplug(),
> so you're statement is wrong, and all you need is pgdat_resize_lock().

They are also initialized at boot without pgdat_resize_lock(), if we 
consider boot time, quite a few of the statements on when locking is 
required are wrong.

That said, you are correct that it is not strictly required to hold 
lock_memory_hotplug() when updating the fields in question because 
pgdat_resize_lock() is used.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
