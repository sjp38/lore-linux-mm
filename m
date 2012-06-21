Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 4D7846B0072
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 01:17:00 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 23:16:58 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D8BBDC90052
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 01:16:32 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5L5GYT136569290
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 01:16:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5L5GXpO021458
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 02:16:33 -0300
Date: Thu, 21 Jun 2012 13:16:30 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
Message-ID: <20120621051630.GA25652@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com>
 <20120621044725.GA20379@shangw>
 <alpine.DEB.2.00.1206202212290.25567@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206202212290.25567@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, minchan@kernel.org, mgorman@suse.de, akpm@linux-foundation.org

>
>> I'm not sure it's the possible to resolve the concerns with "static" here
>> since "allownodes" will be cleared for each call to show_free_areas().
>> 
>> 	static nodemask_t allownodes;
>> 
>
>There's nothing protecting concurrent access to it.  This function 
>certainly isn't in a performance sensitive path so I would be inclined to 
>just leave it as is.
>

Ok. Thanks for comment, David.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
