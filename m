Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id AE9A46B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 18:45:22 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so1061815pbc.41
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 15:45:22 -0800 (PST)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id if4si11579700pbc.346.2014.01.22.15.45.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 15:45:21 -0800 (PST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 23 Jan 2014 09:45:18 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 17C9B2BB0053
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 10:45:16 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0MNQC5x5964098
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 10:26:12 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0MNjFZw019954
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 10:45:15 +1100
Date: Thu, 23 Jan 2014 07:45:13 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <52e05811.a4c3440a.6f6c.1db4SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130429145711.GC1172@dhcp22.suse.cz>
 <20130502105637.GD4441@localhost.localdomain>
 <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
 <20130503030345.GE4441@localhost.localdomain>
 <0000013e6aff6f95-b8fa366e-51a5-4632-962e-1b990520f5a8-000000@email.amazonses.com>
 <20130503153450.GA18709@dhcp22.suse.cz>
 <0000013e6b2e06ab-a26ffcc5-a52d-4165-9be0-025ae813da00-000000@email.amazonses.com>
 <52bd58da.2501440a.6368.16ddSMTPIN_ADDED_BROKEN@mx.google.com>
 <52caac5c.27cb440a.533d.ffffbbd2SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1401211411140.1666@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401211411140.1666@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Han Pingtian <hanpt@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

Hi David,
On Tue, Jan 21, 2014 at 02:12:45PM -0800, David Rientjes wrote:
>On Mon, 6 Jan 2014, Wanpeng Li wrote:
>
>> >Is there any progress against slub's fix?
>> >
>> >MemTotal:        7760960 kB
>> >Slab:            7064448 kB
>> >SReclaimable:     143936 kB
>> >SUnreclaim:      6920512 kB
>> >
>> >112084  10550   9%   16.00K   3507       32   1795584K kmalloc-16384
>> >2497920  48092   1%    0.50K  19515      128   1248960K kmalloc-512 
>> >6058888  89363   1%    0.19K  17768      341   1137152K kmalloc-192
>> >114468  13719  11%    4.58K   2082       55    532992K task_struct 
>> >
>> 
>> This machine has 200 CPUs and 8G memory. There is an oom storm, we are
>> seeing OOM even in boot process.
>> 
>
>Is this still a problem with 3.9 and later kernels?  Please try to 
>reproduce it on 3.13.
>
>If it does reproduce, could you try to pinpoint the problem with kmemleak?  
>Look into Documentation/kmemleak.txt which should identify where these 
>leaks are coming from with your slab allocator of choice. 

We figure out the root issue caused by memoryless node and the patch is 
under testing. 

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
