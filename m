Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B7186B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 03:40:25 -0400 (EDT)
Message-ID: <4A471F01.7010400@redhat.com>
Date: Sun, 28 Jun 2009 10:42:57 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] transcendent memory for Linux
References: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default> <63386a3d0906270618h5be01265v759f5acd1f49682f@mail.gmail.com>
In-Reply-To: <63386a3d0906270618h5be01265v759f5acd1f49682f@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Walleij <linus.ml.walleij@gmail.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, linux-embedded@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 06/27/2009 04:18 PM, Linus Walleij wrote:
> 2009/6/20 Dan Magenheimer<dan.magenheimer@oracle.com>:
>
>    
>> We call this latter class "transcendent memory" and it
>> provides an interesting opportunity to more efficiently
>> utilize RAM in a virtualized environment.  However this
>> "memory but not really memory" may also have applications
>> in NON-virtualized environments, such as hotplug-memory
>> deletion, SSDs, and page cache compression.  Others have
>> suggested ideas such as allowing use of highmem memory
>> without a highmem kernel, or use of spare video memory.
>>      
>
> Here is what I consider may be a use case from the embedded
> world: we have to save power as much as possible, so we need
> to shut off entire banks of memory.
>
> Currently people do things like put memory into self-refresh
> and then sleep, but for long lapses of time you would
> want to compress memory towards lower addresses and
> turn as many banks as possible off.
>
> So we have something like 4x16MB banks of RAM = 64MB RAM,
> and the most necessary stuff easily fits in one of them.
> If we can shut down 3x16MB we save 3 x power supply of the
> RAMs.
>
> However in embedded we don't have any swap, so we'd need
> some call that would attempt to remove a memory by paging
> out code and data that has been demand-paged in
> from the FS but no dirty pages, these should instead be
> moved down to memory which will be retained, and the
> call should fail if we didn't succeed to migrate all
> dirty pages.
>
> Would this be possible with transcendent memory?
>    

You could do this with memory defragmentation, which is needed for 
things like memory hotunplug ayway.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
