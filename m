Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9390D6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 09:29:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so415685250pge.7
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 06:29:32 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b10si5650629pgf.419.2017.03.23.06.29.31
        for <linux-mm@kvack.org>;
        Thu, 23 Mar 2017 06:29:31 -0700 (PDT)
Date: Thu, 23 Mar 2017 13:29:13 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2] kasan: report only the first error by default
Message-ID: <20170323132913.GF9287@leverpostej>
References: <20170322160647.32032-1-aryabinin@virtuozzo.com>
 <20170323114916.29871-1-aryabinin@virtuozzo.com>
 <20170323124154.GE9287@leverpostej>
 <d9be02d7-af87-208a-c51b-c890b549434b@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9be02d7-af87-208a-c51b-c890b549434b@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 23, 2017 at 04:06:59PM +0300, Andrey Ryabinin wrote:
> On 03/23/2017 03:41 PM, Mark Rutland wrote:

> > Rather than trying to pick an arbitrarily large number, how about we use
> > separate flags to determine whether we're in multi-shot mode, and
> > whether a (oneshot) report has been made.
> > 
> > How about the below?
>  
> Yes, it deferentially looks better.
> Can you send a patch with a changelog, or do you want me to care of it?

Would you be happy to take care of it, along with the fixup you
suggested below, as v3?

You can add my:

Signed-off-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.


> >  
> > +#include <linux/bitops.h>
> >  #include <linux/ftrace.h>
> 
> We also need <linux/init.h> for __setup().
> 
> >  #include <linux/kernel.h>
> >  #include <linux/mm.h>
> > @@ -293,6 +294,40 @@ static void kasan_report_error(struct kasan_access_info *info)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
