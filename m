Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7TM4HCP005385
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:04:17 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7TM7oiw186348
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 08:07:50 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7TN4G4G028807
	for <linux-mm@kvack.org>; Thu, 30 Aug 2007 09:04:16 +1000
Message-ID: <46D5ED5C.9030405@linux.vnet.ibm.com>
Date: Thu, 30 Aug 2007 03:34:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH]  Memory controller improve user interface
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop> <1188413148.28903.113.camel@localhost>
In-Reply-To: <1188413148.28903.113.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Wed, 2007-08-29 at 16:40 +0530, Balbir Singh wrote:
>>
>> @@ -352,7 +353,7 @@ int mem_container_charge(struct page *pa
>>                 kfree(pc);
>>                 pc = race_pc;
>>                 atomic_inc(&pc->ref_cnt);
>> -               res_counter_uncharge(&mem->res, 1);
>> +               res_counter_uncharge(&mem->res, MEM_CONTAINER_CHARGE_KB);
>>                 css_put(&mem->css);
>>                 goto done;
>>         } 
> 
> Do these changes really need to happen anywhere besides the
> user<->kernel boundary?  Why can't internal tracking be in pages?

I've thought about this before. The problem is that a user could
set his limit to 10000 bytes, but would then see the usage and
limit round to the closest page boundary. This can be confusing
to a user.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
