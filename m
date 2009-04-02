Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 883C36B004D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 16:14:24 -0400 (EDT)
Message-ID: <49D51CA9.6090601@redhat.com>
Date: Thu, 02 Apr 2009 16:14:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<200903281705.29798.rusty@rustcorp.com.au>	<20090329162336.7c0700e9@skybase>	<200904022232.02185.nickpiggin@yahoo.com.au>	<20090402175249.3c4a6d59@skybase> <49D50CB7.2050705@redhat.com> <49D518E9.1090001@goop.org>
In-Reply-To: <49D518E9.1090001@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Nick Piggin <nickpiggin@yahoo.com.au>, frankeh@watson.ibm.com, virtualization@lists.osdl.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, hugh@veritas.com, Xen-devel <xen-devel@lists.xensource.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> The more complex host policy decisions of how to balance overall 
> memory use system-wide are much in the same for both mechanisms.
Not at all.  Page hinting is just an optimization to host swapping, where
IO can be avoided on many of the pages that hit the end of the LRU.

No decisions have to be made at all about balancing memory use
between guests, it just happens through regular host LRU aging.

Automatic ballooning requires that something on the host figures
out how much memory each guest needs and sizes the guests
appropriately.  All the proposed policies for that which I have
seen have some nasty corner cases or are simply very limited
in scope.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
