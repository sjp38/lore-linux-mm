Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 261006B0206
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 10:19:32 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so1009763pab.12
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 07:19:31 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id yo5si1596982pab.292.2014.03.20.07.19.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 07:19:30 -0700 (PDT)
Message-ID: <532AF8E8.8030101@oracle.com>
Date: Thu, 20 Mar 2014 10:19:20 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: bad rss-counter message in 3.14rc5
References: <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com> <alpine.LSU.2.11.1403181703470.7055@eggly.anvils> <5328F3B4.1080208@oracle.com> <20140319020602.GA29787@redhat.com> <20140319021131.GA30018@redhat.com> <alpine.LSU.2.11.1403181918130.3423@eggly.anvils> <20140319145200.GA4608@redhat.com> <alpine.LSU.2.11.1403192147470.971@eggly.anvils> <20140320135137.GA2263@redhat.com>
In-Reply-To: <20140320135137.GA2263@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On 03/20/2014 09:51 AM, Dave Jones wrote:
> On Wed, Mar 19, 2014 at 10:00:29PM -0700, Hugh Dickins wrote:
>
>   > > This might be collateral damage from the swapops thing, I guess we won't know until
>   > > that gets fixed, but I thought I'd mention that we might still have a problem here.
>   >
>   > Yes, those Bad rss-counters could well be collateral damage from the
>   > swapops BUG.  To which I believe I now have the answer: again untested,
>   > but please give this a try...
>
> This survived an overnight run. No swapops bug, and no bad RSS. Good job:)

Same here, swapops bug is gone!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
