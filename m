Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D545D6B003D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 15:14:14 -0400 (EDT)
Message-ID: <49D11674.9040205@goop.org>
Date: Mon, 30 Mar 2009 11:59:00 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<1238195024.8286.562.camel@nimitz>  <20090329161253.3faffdeb@skybase> <1238428495.8286.638.camel@nimitz> <49D11184.3060002@goop.org> <49D11287.4030307@redhat.com>
In-Reply-To: <49D11287.4030307@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, virtualization@lists.osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Jeremy Fitzhardinge wrote:
>
>> That said, people have been looking at tracking block IO to work out 
>> when it might be useful to try and share pages between guests under Xen.
>
> Tracking block IO seems like a bass-ackwards way to figure
> out what the contents of a memory page are.

Well, they're research projects, so nobody said that they're necessarily 
useful results ;).  I think the rationale is that, in general, there 
aren't all that many sharable pages, and asize from zero-pages, the bulk 
of them are the result of IO.  Since its much simpler to compare 
device+block references than doing page content matching, it is worth 
looking at the IO stream to work out what your candidates are.

> The KVM KSM code has a simpler, yet still efficient, way of
> figuring out which memory pages can be shared.
How's that?  Does it do page content comparison?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
