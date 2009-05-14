Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AAA86B014A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:16:44 -0400 (EDT)
Message-ID: <4A0B61B3.5040702@redhat.com>
Date: Thu, 14 May 2009 03:11:31 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com> <1240191366-10029-2-git-send-email-ieidus@redhat.com> <1240191366-10029-3-git-send-email-ieidus@redhat.com> <1240191366-10029-4-git-send-email-ieidus@redhat.com> <1240191366-10029-5-git-send-email-ieidus@redhat.com> <1240191366-10029-6-git-send-email-ieidus@redhat.com> <20090513161739.d801ab67.akpm@linux-foundation.org> <20090513232520.GN12533@x200.localdomain> <4A0B6283.9040106@codemonkey.ws>
In-Reply-To: <4A0B6283.9040106@codemonkey.ws>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Wright <chrisw@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Anthony Liguori wrote:
> Chris Wright wrote:
>> * Andrew Morton (akpm@linux-foundation.org) wrote:
>>  
>>> Breaks ppc64 allmodcofnig because that architecture doesn't export its
>>> copy_user_page() to modules.
>>>     
>>
>> Things like this and updating to use madvise() I think all point towards
>> s/tristate/bool/.  I don't think CONFIG_KSM=M has huge benefit.
>>   
>
> I agree.

I am sending in one sec, the madvise patch that will kick it away from 
being module anyway...

>
> Regards,
>
> Anthony Liguori
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
