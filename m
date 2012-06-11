Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id B19A86B0087
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:41:04 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 10 Jun 2012 21:41:03 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8F57CC90050
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:40:59 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5B3f0VC128730
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 23:41:00 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5B3ex0F014306
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 00:41:00 -0300
Date: Mon, 11 Jun 2012 12:40:56 +0900
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: cleanup on should_fail_alloc_page
Message-ID: <20120611034056.GA27200@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339253516-8760-1-git-send-email-shangw@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1206101349160.25986@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206101349160.25986@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org

>> In the core function __alloc_pages_nodemask() of buddy allocator, it's
>> possible for the memory allocation to fail. That's probablly caused
>> by error injection with expection. In that case, it depends on the
>> check of error injection covered by function should_fail(). Currently,
>> function should_fail() has "bool" for its return value, so it's reasonable
>> to change the return value of function should_fail_alloc_page() into
>> "bool" as well.
>> 
>
>I think we can remove the first three sentences of this.
>
>> The patch does cleanup on function should_fail_alloc_page() to "bool".
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>
>Acked-by: David Rientjes <rientjes@google.com>
>

Thanks, David. I'll adjust the changelog and send next version
as soon as possible :-)

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
