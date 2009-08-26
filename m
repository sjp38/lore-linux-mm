Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E1CB36B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:18:16 -0400 (EDT)
Received: by pzk6 with SMTP id 6so325697pzk.11
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 09:18:22 -0700 (PDT)
Message-ID: <4A95602A.5040109@vflare.org>
Date: Wed, 26 Aug 2009 21:47:46 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com> <4A92EBB4.1070101@vflare.org> <Pine.LNX.4.64.0908242132320.8144@sister.anvils> <4A930313.9070404@vflare.org> <Pine.LNX.4.64.0908242224530.10534@sister.anvils> <4A93FAA5.5000001@vflare.org> <4A94358C.6060708@vflare.org> <alpine.DEB.1.10.0908261209240.9933@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0908261209240.9933@gentwo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On 08/26/2009 09:40 PM, Christoph Lameter wrote:
> On Wed, 26 Aug 2009, Nitin Gupta wrote:
>
>> I went crazy. I meant 40 bits for PFN -- not 48. This 40-bit PFN should be
>> sufficient for all archs. For archs where 40 + PAGE_SHIFT<  MAX_PHYSMEM_BITS
>> ramzswap will just issue a compiler error.
>
> How about restricting the xvmalloc memory allocator to 32 bit? If I
> understand correctly xvmalloc main use in on 32 bit in order to be
> able to use HIGHMEM?
>
>

I have just replaced all PFN usage with struct page in xvmalloc.

The main use of xvmalloc is not just the use of HIGHMEM -- its just one
of the things. Other reasons are:
  - O(1) alloc/free
  - Low fragmentation
  - Allocates 0-order pages to expand pools

Following gives more information:
http://code.google.com/p/compcache/wiki/xvMalloc
http://code.google.com/p/compcache/wiki/xvMallocPerformance

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
