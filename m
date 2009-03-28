Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3E81F6B003D
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 02:35:04 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Date: Sat, 28 Mar 2009 17:05:28 +1030
References: <20090327150905.819861420@de.ibm.com>
In-Reply-To: <20090327150905.819861420@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903281705.29798.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: virtualization@lists.linux-foundation.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, nickpiggin@yahoo.com.au, frankeh@watson.ibm.com, riel@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Saturday 28 March 2009 01:39:05 Martin Schwidefsky wrote:
> Greetings,
> the circus is back in town -- another version of the guest page hinting
> patches. The patches differ from version 6 only in the kernel version,
> they apply against 2.6.29. My short sniff test showed that the code
> is still working as expected.
> 
> To recap (you can skip this if you read the boiler plate of the last
> version of the patches):
> The main benefit for guest page hinting vs. the ballooner is that there
> is no need for a monitor that keeps track of the memory usage of all the
> guests, a complex algorithm that calculates the working set sizes and for
> the calls into the guest kernel to control the size of the balloons.

I thought you weren't convinced of the concrete benefits over ballooning,
or am I misremembering?

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
