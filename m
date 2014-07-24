Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f47.google.com (mail-oa0-f47.google.com [209.85.219.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFA96B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 20:38:02 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id g18so2719218oah.20
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:38:02 -0700 (PDT)
Received: from mail-oa0-x235.google.com (mail-oa0-x235.google.com [2607:f8b0:4003:c02::235])
        by mx.google.com with ESMTPS id g14si10488649oes.101.2014.07.23.17.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 17:38:01 -0700 (PDT)
Received: by mail-oa0-f53.google.com with SMTP id j17so2756369oag.12
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 17:38:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140723141721.d6a58555f124a7024d010067@linux-foundation.org>
References: <1405616598-14798-1-git-send-email-jcmvbkbc@gmail.com>
	<20140723141721.d6a58555f124a7024d010067@linux-foundation.org>
Date: Thu, 24 Jul 2014 04:38:01 +0400
Message-ID: <CAMo8BfJ0zC16ssBDGUxsLNwmVOpgnyk1PjikunB9u-C7x9uaOA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/highmem: make kmap cache coloring aware
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux/MIPS Mailing List <linux-mips@linux-mips.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, LKML <linux-kernel@vger.kernel.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>

Hi Andrew,

thanks for your feedback, I'll address your points in the next version of this
series.

On Thu, Jul 24, 2014 at 1:17 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> Fifthly, it would be very useful to publish the performance testing
> results for at least one architecture so that we can determine the
> patchset's desirability.  And perhaps to motivate other architectures
> to implement this.

What sort of performance numbers would be relevant?
For xtensa this patch enables highmem use for cores with aliasing cache,
that is access to a gigabyte of memory (typical on KC705 FPGA board) vs.
only 128MBytes of low memory, which is highly desirable. But performance
comparison of these two configurations seems to make little sense.
OTOH performance comparison of highmem variants with and without
cache aliasing would show the quality of our cache flushing code.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
