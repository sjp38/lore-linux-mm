Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 85E586B0093
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:21:36 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so2926464iec.30
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:21:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bt7si17876040icb.70.2014.07.24.15.21.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 15:21:35 -0700 (PDT)
Date: Thu, 24 Jul 2014 15:21:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
Message-Id: <20140724152133.bd4556f632b9cbb506b168cf@linux-foundation.org>
In-Reply-To: <CAMo8BfJ0zC16ssBDGUxsLNwmVOpgnyk1PjikunB9u-C7x9uaOA@mail.gmail.com>
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
	<20140723141721.d6a58555f124a7024d010067@linux-foundation.org>
	<CAMo8BfJ0zC16ssBDGUxsLNwmVOpgnyk1PjikunB9u-C7x9uaOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux/MIPS Mailing List <linux-mips@linux-mips.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, LKML <linux-kernel@vger.kernel.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>

On Thu, 24 Jul 2014 04:38:01 +0400 Max Filippov <jcmvbkbc@gmail.com> wrote:

> On Thu, Jul 24, 2014 at 1:17 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > Fifthly, it would be very useful to publish the performance testing
> > results for at least one architecture so that we can determine the
> > patchset's desirability.  And perhaps to motivate other architectures
> > to implement this.
> 
> What sort of performance numbers would be relevant?
> For xtensa this patch enables highmem use for cores with aliasing cache,
> that is access to a gigabyte of memory (typical on KC705 FPGA board) vs.
> only 128MBytes of low memory, which is highly desirable. But performance
> comparison of these two configurations seems to make little sense.
> OTOH performance comparison of highmem variants with and without
> cache aliasing would show the quality of our cache flushing code.

I'd assumed the patch was making cache coloring available as a
performance tweak.  But you appear to be saying that the (high) memory
is simply unavailable for such cores without this change.  I think.

Please ensure that v3's changelog explains the full reason for the
patch.  Assume you're talking to all-the-worlds-an-x86 dummies, OK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
