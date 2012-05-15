Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 90AA56B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:19:55 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 15 May 2012 05:19:54 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1330E6E804A
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:19:53 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4F9JqqC122806
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:19:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4F9JqTt032592
	for <linux-mm@kvack.org>; Tue, 15 May 2012 05:19:52 -0400
Date: Tue, 15 May 2012 17:19:49 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/slab: remove duplicate check
Message-ID: <20120515091949.GA4887@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1336727769-19555-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120514204219.GC1406@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120514204219.GC1406@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

>> While allocateing pages using buddy allocator, the compound page
>> is probably split up to free pages. Under the circumstance, the
>> compound page should be destroied by function destroy_compound_page().
>> However, there has duplicate check to judge if the page is compound
>> one.
>> 
>> The patch removes the duplicate check since the function compound_order()
>> will returns 0 while the page hasn't PG_head set in function destroy_compound_page().
>> That's to say, the function destroy_compound_page() needn't check
>> PG_head any more through function PageHead().
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>
>Looks good!
>
>But the slab in the subject suggests it would not affect other parts
>of mm, while it actually affects THP, too.  Should probably be
>removed?
>
>Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>

Thanks for looking into this, Johannes :-)

I'm not sure I should change the subject to "mm: xxx" and resend it
since it has been put into linux-mm next tree as the maillist mm-commits
told me. By the way, I even don't know how linux-mm next got sychronized
with linux mainline yet :-)

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
