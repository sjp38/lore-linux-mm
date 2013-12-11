Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBB66B0037
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 11:04:45 -0500 (EST)
Received: by mail-oa0-f52.google.com with SMTP id h16so7475858oag.39
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:04:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f6si13828107obr.20.2013.12.11.08.04.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 08:04:44 -0800 (PST)
Message-ID: <52A88AFB.7000204@oracle.com>
Date: Wed, 11 Dec 2013 10:55:39 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: kernel BUG in munlock_vma_pages_range
References: <52A3D0C3.1080504@oracle.com> <52A58E8A.3050401@suse.cz> <52A5F83F.4000207@oracle.com> <alpine.LRH.2.00.1312092215340.1515@twin.jikos.cz>
In-Reply-To: <alpine.LRH.2.00.1312092215340.1515@twin.jikos.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, joern@logfs.org, mgorman@suse.de, Michel Lespinasse <walken@google.com>, riel@redhat.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12/09/2013 04:16 PM, Jiri Kosina wrote:
> On Mon, 9 Dec 2013, Sasha Levin wrote:
>
>> Not really, the fuzzer hit it once and I've been unable to trigger it
>> again.
>
> If you are ever able to trigger it again, I think having crashdump
> available would be very helpful here, to see how exactly does the VMA/THP
> layout look like at the time of crash.
>
> Any chance you run your fuzzing with crashkernel configured for a while?
>

Been trying to, can't get crashkernel to interact nicely with my KVM tools guest.

Will keep trying.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
