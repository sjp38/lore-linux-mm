Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 54E596B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 16:45:05 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 02:09:58 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 89041394005C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 02:14:57 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AKirfY852300
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 02:14:54 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AKiuuX015774
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 06:44:56 +1000
Message-ID: <5165CEB0.3010504@linux.vnet.ibm.com>
Date: Thu, 11 Apr 2013 02:12:24 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Simplify for_each_populated_zone()
References: <20130410202727.20368.29222.stgit@srivatsabhat.in.ibm.com> <alpine.DEB.2.02.1304101339260.25932@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1304101339260.25932@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On 04/11/2013 02:11 AM, David Rientjes wrote:
> On Thu, 11 Apr 2013, Srivatsa S. Bhat wrote:
> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index ede2749..2489042 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -948,9 +948,7 @@ extern struct zone *next_zone(struct zone *zone);
>>  	for (zone = (first_online_pgdat())->node_zones; \
>>  	     zone;					\
>>  	     zone = next_zone(zone))			\
>> -		if (!populated_zone(zone))		\
>> -			; /* do nothing */		\
>> -		else
>> +		if (populated_zone(zone))
>>  
>>  static inline struct zone *zonelist_zone(struct zoneref *zoneref)
>>  {
> 
> Nack, it's written the way it is to avoid ambiguous else statements 
> following it.  People do things like
> 
> 	for_each_populated_zone(z)
> 		if (...) {
> 		} else (...) {
> 		}
> 
> and it's now ambiguous (and should warn with -Wparentheses).
> 

Hmm, fair enough. Please ignore this patch then. Thanks!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
