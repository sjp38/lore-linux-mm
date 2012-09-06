Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 23A096B00B3
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 23:05:22 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wangyun@linux.vnet.ibm.com>;
	Thu, 6 Sep 2012 13:04:51 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8635E3P28836022
	for <linux-mm@kvack.org>; Thu, 6 Sep 2012 13:05:14 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8635Dsa009069
	for <linux-mm@kvack.org>; Thu, 6 Sep 2012 13:05:13 +1000
Message-ID: <504812E7.3000700@linux.vnet.ibm.com>
Date: Thu, 06 Sep 2012 11:05:11 +0800
From: Michael Wang <wangyun@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: fix the DEADLOCK issue on l3 alien lock
References: <5044692D.7080608@linux.vnet.ibm.com> <5046B9EE.7000804@linux.vnet.ibm.com> <0000013996b6f21d-d45be653-3111-4aef-b079-31dc673e6fd8-000000@email.amazonses.com>
In-Reply-To: <0000013996b6f21d-d45be653-3111-4aef-b079-31dc673e6fd8-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@kernel.org>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On 09/05/2012 09:55 PM, Christoph Lameter wrote:
> On Wed, 5 Sep 2012, Michael Wang wrote:
> 
>> Since the cachep and cachep->slabp_cache's l3 alien are in the same lock class,
>> fake report generated.
> 
> Ahh... That is a key insight into why this occurs.
> 
>> This should not happen since we already have init_lock_keys() which will
>> reassign the lock class for both l3 list and l3 alien.
> 
> Right. I was wondering why we still get intermitted reports on this.
> 
>> This patch will invoke init_lock_keys() after we done enable_cpucache()
>> instead of before to avoid the fake DEADLOCK report.
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Thanks for your review.

And add Paul to the cc list(my skills on mailing is really poor...).

Regards,
Michael Wang

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
