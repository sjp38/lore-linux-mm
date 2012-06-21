Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id E3D886B00A7
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:12:41 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 21 Jun 2012 05:12:38 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 950A838C803A
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:11:58 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5L9BwgP176666
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 05:11:58 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5L9Bu3S006646
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 03:11:56 -0600
Date: Thu, 21 Jun 2012 17:11:53 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: get the allownodes for dump at once
Message-ID: <20120621091153.GA7257@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339662910-25774-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206201815100.3702@chino.kir.corp.google.com>
 <jruo1o$j9v$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <jruo1o$j9v$1@dough.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: linux-mm@kvack.org

>>
>> show_free_areas() is called by the oom killer, so we know two things: it 
>> can be called potentially very deep in the callchain and current is out of 
>> memory.  Both are killers for this patch since you're allocating 
>> nodemask_t on the stack here which could cause an overflow and because you 
>> can't easily fix that case with NODEMASK_ALLOC() since it allocates slab 
>> with GFP_KERNEL when we we're oom, which would simply suppress vital 
>> meminfo from being shown.
>>
>
>Adding a comment in the beginning of show_free_areas() would be nice,
>to tell people not to allocate more memory either on stack or in heap.
>

Thanks, Cong. I'll do it later :-)

Thanks,
Gavin

>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
