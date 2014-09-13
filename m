Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id B5D106B0035
	for <linux-mm@kvack.org>; Sat, 13 Sep 2014 01:41:52 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2724385pab.1
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 22:41:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id je1si6331779pbb.168.2014.09.12.22.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 22:41:51 -0700 (PDT)
Date: Fri, 12 Sep 2014 22:42:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 4/6] mm: introduce common page state for ballooned
 memory
Message-Id: <20140912224221.9ee5888a.akpm@linux-foundation.org>
In-Reply-To: <CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164120.29066.8857.stgit@zurg>
	<20140912165143.86d5f83dcde4a9fd78069f79@linux-foundation.org>
	<CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, 13 Sep 2014 09:26:49 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> >
> > Did we really need to put the BalloonPages count into per-zone vmstat,
> > global vmstat and /proc/meminfo?  Seems a bit overkillish - why so
> > important?
> 
> Balloon grabs random pages, their distribution among numa nodes might
> be important.
> But I know nobody who uses numa-aware vm together with ballooning.
> 
> Probably it's better to drop per-zone vmstat and line from meminfo,
> global vmstat counter should be enough.

Yes, the less we add the better - we can always add stuff later if
there is a demonstrated need.

> >
> > Consuming another page flag is a big deal.  We keep on nearly running
> > out and one day we'll run out for real.  page-flags-layout.h is
> > incomprehensible.  How many flags do we have left (worst-case) with this
> > change?  Is there no other way?  Needs extraordinary justification,
> > please.
> 
> PageBalloon is not a page flags, it's like PageBuddy -- special state
> of _mapcount (-256 in this case).
> The same was in v1 and is written in the comment above.

oop sorry, I got confused about KPF_BALLOON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
