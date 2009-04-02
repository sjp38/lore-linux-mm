Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 620966B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 15:06:46 -0400 (EDT)
Message-ID: <49D50CB7.2050705@redhat.com>
Date: Thu, 02 Apr 2009 15:06:31 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<200903281705.29798.rusty@rustcorp.com.au>	<20090329162336.7c0700e9@skybase>	<200904022232.02185.nickpiggin@yahoo.com.au> <20090402175249.3c4a6d59@skybase>
In-Reply-To: <20090402175249.3c4a6d59@skybase>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, frankeh@watson.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> The benefits are the same but the algorithmic complexity is reduced.
> The patch to the memory management has complexity in itself but from a
> 1000 feet standpoint guest page hinting is simpler, no? 
Page hinting has a complex, but well understood, mechanism
and simple policy.

Ballooning has a simpler mechanism, but relies on an
as-of-yet undiscovered policy.

Having experienced a zillion VM corner cases over the
last decade and a bit, I think I prefer a complex mechanism
over complex (or worse, unknown!) policy any day.
> Ok, I can understand that. We probably need a KVM based version to show
> that benefits exist on non-s390 hardware as well.
I believe it can work for KVM just fine, if we keep the host state
and the guest state in separate places (so the guest can always
write the guest state without a hypercall).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
