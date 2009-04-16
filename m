Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 705A25F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 12:08:42 -0400 (EDT)
Message-ID: <49E7580A.1080903@goop.org>
Date: Thu, 16 Apr 2009 09:08:42 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com> <1239249521-5013-2-git-send-email-ieidus@redhat.com> <1239249521-5013-3-git-send-email-ieidus@redhat.com> <1239249521-5013-4-git-send-email-ieidus@redhat.com> <1239249521-5013-5-git-send-email-ieidus@redhat.com> <20090414150929.174a9b25.akpm@linux-foundation.org> <49E67F17.1070805@goop.org> <20090416113931.GF4524@random.random>
In-Reply-To: <20090416113931.GF4524@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Wed, Apr 15, 2009 at 05:43:03PM -0700, Jeremy Fitzhardinge wrote:
>   
>> Shouldn't that be kmap_atomic's job anyway?  Otherwise it would be hard to 
>>     
>
> No because those are full noops in no-highmem kernels. I commented in
> other email why I think it's safe thanks to the wrprotect + smp tlb
> flush of the userland PTE.
>   

I think Andrew's query was about data cache synchronization in 
architectures with virtually indexed d-cache.  On x86 it's a non-issue, 
but on architectures for which it is an issue, I assume kmap_atomic does 
any necessary cache flushes, as it does tlb flushes on x86 (which may be 
none at all, if no mapping actually happens).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
