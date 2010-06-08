Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A11926B01B2
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 01:41:21 -0400 (EDT)
Received: by bwz1 with SMTP id 1so1368559bwz.14
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 22:41:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006071729560.12482@router.home>
References: <20100521211452.659982351@quilx.com>
	<20100521211537.530913777@quilx.com>
	<alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006071729560.12482@router.home>
Date: Tue, 8 Jun 2010 08:41:19 +0300
Message-ID: <AANLkTikOKy6ZQQh2zORJDvGDE0golvyzsvlvDj-P5cur@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
	node.
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 8, 2010 at 1:30 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Mon, 7 Jun 2010, David Rientjes wrote:
>
>> On Fri, 21 May 2010, Christoph Lameter wrote:
>>
>> > kmalloc_node() and friends can be passed a constant -1 to indicate
>> > that no choice was made for the node from which the object needs to
>> > come.
>> >
>> > Add a constant for this.
>> >
>>
>> I think it would be better to simply use the generic NUMA_NO_NODE for this
>> purpose, which is identical to how hugetlb, pxm mappings, etc, use it to
>> specify no specific node affinity.
>
> Ok will do that in the next release.

Patches 1-5 are queued for 2.6.36 so please send an incremental patch
on top of 'slub/cleanups' branch of slab.git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
