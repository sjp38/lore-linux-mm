From: Andi Kleen <ak@suse.de>
Subject: Re: X86_CONFIG overrides X86_L1_CACHE_SHIFT default for each CPU model.
Date: Fri, 4 Nov 2005 23:39:57 +0100
References: <4367CB17.6050200@gmail.com>
In-Reply-To: <4367CB17.6050200@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511042339.57785.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jim Cromie <jim.cromie@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 01 November 2005 21:07, Jim Cromie wrote:
> folks,
>
> in arch/i386/Kconfig, it seems (to me) that X86_GENERIC has undue influence
> on X86_L1_CACHE_SHIFT;
>
> config X86_L1_CACHE_SHIFT
>       int
>       default "7" if MPENTIUM4 || X86_GENERIC
>       default "4" if X86_ELAN || M486 || M386
>       default "5" if MWINCHIP3D || MWINCHIP2 || MWINCHIPC6 || MCRUSOE ||
> MEFFICEON || MCYRIXIII || MK6 || MPENTIUMIII || MPENTIUMII || M686 ||
> M586MMX || M586TSC || M586 || MVIAC3_2 || MGEODEGX1
>       default "6" if MK7 || MK8 || MPENTIUMM
>
> that is, when X86_GENERIC == true --> default = 7,
> ignoring the platform choice *made* by the user-builder.
> On my geode box, it would be 5 wo GENERIC.

The whole point of GENERIC is to set the cache line size to the worst case
(which is 128 bytes)  so that the kernel will run reasonably well on all 
systems.


> Ill spare you my half-baked theories about the cause of these results,
> in the hopes that the following patch 'correct-by-inspection', or that
> somebody
> is willing to clarify the purposes of X86_GENERIC.

Your patch is wrong.

> An 'incorrect' guess at cache-line-size doesnt break the kernel;
> is the number used to optimize the cache operation in a way
> thats consistent with the above results ?

It only causes some more padding, which is normally performance neutral.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
