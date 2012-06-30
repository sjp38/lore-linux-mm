Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id AA8A86B009B
	for <linux-mm@kvack.org>; Sat, 30 Jun 2012 05:43:30 -0400 (EDT)
Received: by wibhr14 with SMTP id hr14so1251771wib.7
        for <linux-mm@kvack.org>; Sat, 30 Jun 2012 02:43:28 -0700 (PDT)
Message-ID: <4FEECA3C.5070308@ravellosystems.com>
Date: Sat, 30 Jun 2012 12:43:24 +0300
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] KSM: numa awareness sysfs knob
References: <1340970592-25001-1-git-send-email-pholasek@redhat.com> <20120629141759.3312b49e.akpm@linux-foundation.org> <alpine.DEB.2.00.1206291543360.17044@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206291543360.17044@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On 06/30/2012 01:50 AM, David Rientjes wrote:
> On Fri, 29 Jun 2012, Andrew Morton wrote:
>
>>> I've tested this patch on numa machines with 2, 4 and 8 nodes and
>>> measured speed of memory access inside of KVM guests with memory pinned
>>> to one of nodes with this benchmark:
>>>
>>> http://pholasek.fedorapeople.org/alloc_pg.c
>>>
>>> Population standard deviations of access times in percentage of average
>>> were following:
>>>
>>> merge_nodes=1
>>> 2 nodes 1.4%
>>> 4 nodes 1.6%
>>> 8 nodes	1.7%
>>>
>>> merge_nodes=0
>>> 2 nodes	1%
>>> 4 nodes	0.32%
>>> 8 nodes	0.018%
>> ooh, numbers!  Thanks.
>>
> Ok, the standard deviation increases when merging pages from nodes with
> remote distance, that makes sense.  But if that's true, then you would
> restrict either the entire application to local memory with mempolicies or
> cpusets, or you would use mbind() to restrict this memory to that set of
> nodes already so that accesses, even with ksm merging, would have
> affinity.

While you are right for case you write your own custom application,
but I think the KVM guest case is little bit more problomatic in case 
the guest memory must be splitted across serval nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
