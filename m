Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 678CF6B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 20:29:22 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 26 Jun 2012 20:29:21 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C78C76E804C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 20:29:18 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5R0TI0W133282
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 20:29:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5R0TIs2015112
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 20:29:18 -0400
Date: Wed, 27 Jun 2012 08:29:15 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/5] mm/sparse: more check on mem_section number
Message-ID: <20120627002915.GA4066@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1340466776-4976-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1340466776-4976-4-git-send-email-shangw@linux.vnet.ibm.com>
 <4FE9E028.7010006@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE9E028.7010006@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -160,6 +160,8 @@ int __section_nr(struct mem_section* ms)
>>  		     break;
>>  	}
>> 
>> +	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
>> +
>>  	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
>>  }
>
>If you're going to bother with a VM_BUG_ON(), I'd probably make it:
>
>	VM_BUG_ON(root_nr >= NR_SECTION_ROOTS);

Thanks, I'll change it according to your suggestion in next revision.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
