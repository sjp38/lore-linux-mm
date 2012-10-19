Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CC1CA6B0070
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:27:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Sat, 20 Oct 2012 00:24:40 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9JERADw44040296
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 01:27:11 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9JERA2j012078
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 01:27:10 +1100
Message-ID: <5081630B.2000004@linux.vnet.ibm.com>
Date: Fri, 19 Oct 2012 19:56:19 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Simplify for_each_populated_zone()
References: <20121019105546.9704.93446.stgit@srivatsabhat.in.ibm.com> <20121019135454.GJ31863@cmpxchg.org>
In-Reply-To: <20121019135454.GJ31863@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kosaki.motohiro@gmail.com, akpm@linux-foundation.org

On 10/19/2012 07:24 PM, Johannes Weiner wrote:
> On Fri, Oct 19, 2012 at 04:25:47PM +0530, Srivatsa S. Bhat wrote:
>> Move the check for populated_zone() to the control statement of the
>> 'for' loop and get rid of the odd looking if/else block.
>>
>> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
>> ---
>>
>>  include/linux/mmzone.h |    7 ++-----
>>  1 file changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 50aaca8..5bdf02e 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -913,11 +913,8 @@ extern struct zone *next_zone(struct zone *zone);
>>  
>>  #define for_each_populated_zone(zone)		        \
>>  	for (zone = (first_online_pgdat())->node_zones; \
>> -	     zone;					\
>> -	     zone = next_zone(zone))			\
>> -		if (!populated_zone(zone))		\
>> -			; /* do nothing */		\
>> -		else
>> +	     zone && populated_zone(zone);		\
>> +	     zone = next_zone(zone))
> 
> I don't think we want to /abort/ the loop when encountering an
> unpopulated zone.
> 

Oops! I totally missed that.. thanks for catching it! Please ignore
the patch.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
