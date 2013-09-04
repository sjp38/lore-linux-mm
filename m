Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 382726B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 23:38:16 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 4 Sep 2013 09:00:04 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 54BCD1258052
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 09:08:04 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r843c44j48824464
	for <linux-mm@kvack.org>; Wed, 4 Sep 2013 09:08:05 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r843c6vG005561
	for <linux-mm@kvack.org>; Wed, 4 Sep 2013 09:08:06 +0530
Date: Wed, 4 Sep 2013 11:38:04 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/16] slab: overload struct slab over struct page to
 reduce memory usage
Message-ID: <20130904033804.GA825@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
 <00000140a6ec66e5-a4d245c0-76b6-4a8b-9cf0-d941ca9e08b0-000000@email.amazonses.com>
 <20130823063539.GD22605@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130823063539.GD22605@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Joonsoo,
On Fri, Aug 23, 2013 at 03:35:39PM +0900, Joonsoo Kim wrote:
>On Thu, Aug 22, 2013 at 04:47:25PM +0000, Christoph Lameter wrote:
>> On Thu, 22 Aug 2013, Joonsoo Kim wrote:
>
[...]
>struct slab's free = END
>kmem_bufctl_t array: ACTIVE ACTIVE ACTIVE ACTIVE ACTIVE
><we get object at index 0>
>

Is there a real item for END in kmem_bufctl_t array as you mentioned above?
I think the kmem_bufctl_t array doesn't include that and the last step is 
not present. 

Regards,
Wanpeng Li 

[...]

>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
