Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 03C546B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 01:54:57 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so3137893eei.5
        for <linux-mm@kvack.org>; Thu, 22 May 2014 22:54:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n43si4359706eea.24.2014.05.22.22.54.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 22:54:56 -0700 (PDT)
Message-ID: <537EE2AF.4070307@suse.cz>
Date: Fri, 23 May 2014 07:54:55 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: 3.15.0-rc6: VM_BUG_ON_PAGE(PageTail(page), page)
References: <20140522135828.GA24879@redhat.com> <537ECCDB.8080009@oracle.com>
In-Reply-To: <537ECCDB.8080009@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 23.5.2014 6:21, Sasha Levin wrote:
> On 05/22/2014 09:58 AM, Dave Jones wrote:
>> Not sure if Sasha has already reported this on -next (It's getting hard
>> to keep track of all the VM bugs he's been finding), but I hit this overnight
>> on .15-rc6.  First time I've seen this one.
> Unfortunately I had to disable transhuge/hugetlb in my testing .config since
> the open issues in -next get hit pretty often, and were unfixed for a while
> now.

Meh, I lost track. We should really consider something like bugzilla for 
this, IMHO.

> Keeping them enabled just made it impossible to test anything else.
>
>
> Thanks,
> Sasha
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
