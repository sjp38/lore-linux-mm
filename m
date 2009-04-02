Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9D4486B004F
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 15:22:16 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 0/6] Guest page hinting version 7.
Date: Fri, 3 Apr 2009 06:22:29 +1100
References: <20090327150905.819861420@de.ibm.com> <20090402175249.3c4a6d59@skybase> <49D50CB7.2050705@redhat.com>
In-Reply-To: <49D50CB7.2050705@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200904030622.30935.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Rusty Russell <rusty@rustcorp.com.au>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, akpm@osdl.org, frankeh@watson.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Friday 03 April 2009 06:06:31 Rik van Riel wrote:
> Martin Schwidefsky wrote:
> > The benefits are the same but the algorithmic complexity is reduced.
> > The patch to the memory management has complexity in itself but from a
> > 1000 feet standpoint guest page hinting is simpler, no? 
> Page hinting has a complex, but well understood, mechanism
> and simple policy.
> 
> Ballooning has a simpler mechanism, but relies on an
> as-of-yet undiscovered policy.
> 
> Having experienced a zillion VM corner cases over the
> last decade and a bit, I think I prefer a complex mechanism
> over complex (or worse, unknown!) policy any day.

I disagree with it being so clear cut. Volatile pagecache policy is completely
out of the control of the Linux VM. Wheras ballooning does have to make some
tradeoff between guests, but the actual reclaim will be driven by the guests.
Neither way is perfect, but it's not like the hypervisor reclaim is foolproof
against making a bad tradeoff between guests.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
