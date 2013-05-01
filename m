Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id F0C6C6B01FA
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:45:22 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 16:45:22 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B574619D8046
	for <linux-mm@kvack.org>; Wed,  1 May 2013 16:44:57 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41Mj3Bk090396
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:45:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41Mj2gt011784
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:45:03 -0600
Message-ID: <51819AED.9090408@linux.vnet.ibm.com>
Date: Wed, 01 May 2013 15:45:01 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mmzone: make holding lock_memory_hotplug() a requirement
 for updating pgdat size
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-2-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011525580.8804@chino.kir.corp.google.com> <518197E2.7050004@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011539010.8804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1305011539010.8804@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2013 03:39 PM, David Rientjes wrote:
> On Wed, 1 May 2013, Cody P Schafer wrote:
>
>> They are also initialized at boot without pgdat_resize_lock(), if we consider
>> boot time, quite a few of the statements on when locking is required are
>> wrong.
>>
>> That said, you are correct that it is not strictly required to hold
>> lock_memory_hotplug() when updating the fields in question because
>> pgdat_resize_lock() is used.
>>
>
> I think you've confused node size fields with zone size fields.
>

Where? I'm afraid I don't see where I'm mixing them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
