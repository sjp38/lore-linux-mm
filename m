Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DB1706B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 23:06:14 -0400 (EDT)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 23:06:13 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 56E6A6E8053
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 23:06:10 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5L36Alt199830
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 23:06:10 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5L369qT010253
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 00:06:09 -0300
Date: Thu, 21 Jun 2012 11:06:05 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH RESEND 1/2] mm/compaction: cleanup on compaction_deferred
Message-ID: <20120621030605.GA6846@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340156348-18875-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206201824550.3702@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206201824550.3702@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, hannes@cmpxchg.org, minchan@kernel.org, akpm@linux-foundation.org

>> When CONFIG_COMPACTION is enabled, compaction_deferred() tries
>> to recalculate the deferred limit again, which isn't necessary.
>> 
>> When CONFIG_COMPACTION is disabled, compaction_deferred() should
>> return "true" or "false" since it has "bool" for its return value.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Acked-by: Minchan Kim <minchan@kernel.org>
>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
>Acked-by: David Rientjes <rientjes@google.com>
>

Thanks, David :-)

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
