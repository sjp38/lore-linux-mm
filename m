Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id C1DD76B0036
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 01:35:33 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id j107so1879819qga.36
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 22:35:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si10586113qad.33.2014.08.14.22.35.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Aug 2014 22:35:33 -0700 (PDT)
Date: Fri, 15 Aug 2014 02:21:37 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: mm: compaction: buffer overflow in isolate_migratepages_range
Message-ID: <20140815052136.GC26367@optiplex.redhat.com>
References: <CAPAsAGwk7kF6XtJNz6Y41zn0SHHzEt1Nwi_wC0gWgt0fpdp-ZQ@mail.gmail.com>
 <26c3333933769e4f9d1ed6226962a2f80719146b.1408050002.git.aquini@redhat.com>
 <20140814220704.GB26367@optiplex.redhat.com>
 <CALYGNiPbtav_ChUFW_kkh+HOHVmKeupTRsnKsaShK=p8ZKguBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPbtav_ChUFW_kkh+HOHVmKeupTRsnKsaShK=p8ZKguBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, rientjes@google.com, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrey Ryabinin <a.ryabinin@samsung.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com

On Fri, Aug 15, 2014 at 07:36:16AM +0400, Konstantin Khlebnikov wrote:
> Don't hurry. The code in this state for years.
> I'm working on patches for this, if everything goes well I'll show it today.
> As usual I couldn't stop myself from cleaning the mess, so it will be
> bigger than yours.
>
Sorry,

I didn't see this reply of yours before sending out an adjusted-and-tested 
version of that patch, and asked Sasha to check it against his test-case.

Please, do not hesitate in providing your change ideas, though. I'd really
appreciate your assessment feedback on that code. 

Cheers,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
