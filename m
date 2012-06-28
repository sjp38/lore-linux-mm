Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 88A986B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:18:33 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 28 Jun 2012 02:18:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id DE35E38C801D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:18:13 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5S6IDWg181232
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 02:18:13 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5S6IDAZ027072
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 03:18:13 -0300
Date: Thu, 28 Jun 2012 14:18:10 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/3] mm/sparse: more check on mem_section number
Message-ID: <20120628061810.GB27958@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340814968-2948-3-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206271506260.22985@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206271506260.22985@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, mhocko@suse.cz, dave@linux.vnet.ibm.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On Wed, Jun 27, 2012 at 03:06:52PM -0700, David Rientjes wrote:
>On Thu, 28 Jun 2012, Gavin Shan wrote:
>
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index a803599..8b8250e 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -149,6 +149,8 @@ int __section_nr(struct mem_section* ms)
>>  		     break;
>>  	}
>>  
>> +	VM_BUG_ON(root_nr >= NR_SECTION_ROOTS);
>> +
>
>VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
>

Thanks, David. I will change it according to your comments.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
