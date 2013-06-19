Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 8288B6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:06:07 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 17:06:06 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A7DE31FF0020
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 17:00:50 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5JN64LO144896
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 17:06:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5JN63jd019994
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 17:06:03 -0600
Message-ID: <51C23958.9020108@linux.vnet.ibm.com>
Date: Wed, 19 Jun 2013 16:06:00 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in
 __zone_pcp_update()
References: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com> <51C176AC.4000709@linux.vnet.ibm.com> <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 06/19/2013 03:53 PM, David Rientjes wrote:
> On Wed, 19 Jun 2013, Srivatsa S. Bhat wrote:
>
>>> __zone_pcp_update() is called via stop_machine(), which already disables
>>> local irq.
>>>
>>>   mm/page_alloc.c | 4 +---
>>>   1 file changed, 1 insertion(+), 3 deletions(-)
>
> This seems like a fine cleanup because stop_machine() disable irqs, but it
> appears like there is two problems with this function already:
>

Re-examining this, I've realized that my previous patchset containing
	"mm/page_alloc: convert zone_pcp_update() to rely on memory barriers 
instead of stop_machine()"

already went through and fixed this up (the right way). So ignore this 
patch.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
