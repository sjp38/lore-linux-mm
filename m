Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C67D96B0208
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:51:06 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 16:51:05 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id C5CAF19D804E
	for <linux-mm@kvack.org>; Wed,  1 May 2013 16:50:56 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41Mp2qF358008
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:51:02 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41Mru5c009920
	for <linux-mm@kvack.org>; Wed, 1 May 2013 16:53:57 -0600
Message-ID: <51819C54.3030704@linux.vnet.ibm.com>
Date: Wed, 01 May 2013 15:51:00 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] memory_hotplug: use pgdat_resize_lock() when updating
 node_present_pages
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com> <1367446635-12856-5-git-send-email-cody@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011530050.8804@chino.kir.corp.google.com> <518199FE.7060908@linux.vnet.ibm.com> <alpine.DEB.2.02.1305011547450.8804@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1305011547450.8804@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/01/2013 03:48 PM, David Rientjes wrote:
> On Wed, 1 May 2013, Cody P Schafer wrote:
>
>> Guaranteed to be stable means that if I'm a reader and pgdat_resize_lock(),
>> node_present_pages had better not change at all until I pgdat_resize_unlock().
>>
>> If nothing needs this guarantee, we should change the rules of
>> pgdat_resize_lock(). I played it safe and went with following the existing
>> rules.
>>
>
> __offline_pages() breaks your guarantee.
>

Thanks for pointing that out. Seems I fixed online_pages() but missed 
__offline_pages().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
