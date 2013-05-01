Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1E8BA6B0206
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:48:12 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 18:48:11 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C3016C90028
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:48:00 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41Mm0MA260100
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:48:01 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41Mm0Cx026205
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:48:00 -0600
Message-ID: <51819B9F.3090407@linux.vnet.ibm.com>
Date: Wed, 01 May 2013 15:47:59 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mmzone: note that node_size_lock should be manipulated
 via pgdat_resize_lock()
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-4-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011528550.8804@chino.kir.corp.google.com> <51819900.1010301@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011541260.8804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1305011541260.8804@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2013 03:42 PM, David Rientjes wrote:
> On Wed, 1 May 2013, Cody P Schafer wrote:
>
>>>> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
>>>
>>> Nack, pgdat_resize_unlock() is unnecessary if irqs are known to be
>>> disabled.
>>>
>>
>> All this patch does is is indicate that rather than using node_size_lock
>> directly (as it won't be around without CONFIG_MEMORY_HOTPLUG), one should use
>> the pgdat_resize_[un]lock() helper macros.
>>
>
> I think that's obvious given the lock is surrounded by
> #ifdef CONFIG_MEMORY_HOTPLUG.  The fact remains that hotplug code need not
> use pgdat_resize_lock() if irqs are disabled.
>

Obvious how? This comment is the documentation on how to handle locking 
of pg_data_t, and doesn't mention pgdat_resize_lock() at all. Sure, a 
newcomer would probably find pgdat_resize_lock() eventually, even more 
so if they were interested in performance gains from not re-disabling 
local irqs.

I don't see a convincing reason to omit relevant documentation and make 
it more difficult to find the "right" way to do things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
