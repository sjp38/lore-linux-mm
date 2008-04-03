From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [PATCH 3/6] compcache: TLSF Allocator interface
Date: Thu, 3 Apr 2008 22:53:43 +0530
Message-ID: <4cefeab80804031023m10924d6n9e21f6cb792f5d76@mail.gmail.com>
References: <200803242034.24264.nitingupta910@gmail.com>
	 <1206377777.6437.123.camel@lappy>
	 <4cefeab80803241034m6f62c01fq669129db9959f47f@mail.gmail.com>
	 <1206385013.6437.140.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761543AbYDCRX4@vger.kernel.org>
In-Reply-To: <1206385013.6437.140.camel@lappy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Tue, Mar 25, 2008 at 12:26 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

>  Yeah, it also suffers from a horrible coding style, can use excessive
>  amounts of vmalloc space, isn't hooked into the reclaim process as an
>  allocator should be and has a severe lack of per-cpu data making it a
>  pretty big bottleneck on anything with more than a few cores.
>
>  Now, it might be needed, might work better, and the scalability issue
>  might not be a problem when used for swap, but still, you don't treat
>  any of these points in your changelog.
>


I will add these points to changelog.
This project is meant for small systems only. So, scalability is not an issue.


>  FWIW, please split up the patches in a sane way. This series looks like
>  it wants to be 2 or 3 patches. The first introducing all of TLSF (this
>  split per file is horrible). The second doing all of the block device,
>  and a possible last doing documentation and such.
>

Ok. I will resend with better splitting.


>  Also, how bad was kmalloc() compared to this TLSF, we need numbers :-)
>
>

I have posted performance numbers at:
http://code.google.com/p/compcache/wiki/AllocatorsComparison

Data Summary:

Peak Memory Usage:

    * Ideal: 24947 KB
    * TLSF: 25377 KB
    * KMalloc(SLUB): 36483 KB

So, KMalloc uses ~43% more memory than TLSF!


- Nitin
