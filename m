Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 082D96B006A
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:19:35 -0400 (EDT)
Received: by bwz24 with SMTP id 24so261799bwz.38
        for <linux-mm@kvack.org>; Wed, 26 Aug 2009 09:19:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0908261209240.9933@gentwo.org>
References: <200908241007.47910.ngupta@vflare.org>
	 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
	 <4A92EBB4.1070101@vflare.org>
	 <Pine.LNX.4.64.0908242132320.8144@sister.anvils>
	 <4A930313.9070404@vflare.org>
	 <Pine.LNX.4.64.0908242224530.10534@sister.anvils>
	 <4A93FAA5.5000001@vflare.org> <4A94358C.6060708@vflare.org>
	 <alpine.DEB.1.10.0908261209240.9933@gentwo.org>
Date: Wed, 26 Aug 2009 19:19:40 +0300
Message-ID: <84144f020908260919ke9d6c34qb47c3015ee0ca89b@mail.gmail.com>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009, Nitin Gupta wrote:
>> I went crazy. I meant 40 bits for PFN -- not 48. This 40-bit PFN should be
>> sufficient for all archs. For archs where 40 + PAGE_SHIFT < MAX_PHYSMEM_BITS
>> ramzswap will just issue a compiler error.

On Wed, Aug 26, 2009 at 7:10 PM, Christoph
Lameter<cl@linux-foundation.org> wrote:
> How about restricting the xvmalloc memory allocator to 32 bit? If I
> understand correctly xvmalloc main use in on 32 bit in order to be
> able to use HIGHMEM?

That was the main reason for a specialized allocator rather than
trying to use SLOB. However, if "xvmalloc" is merged with ramzswap, it
makes sense to use it on desktop class 64-bit machines as well.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
