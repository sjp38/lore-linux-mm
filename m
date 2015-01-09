Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5366B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 11:46:01 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id hq11so3508502vcb.9
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 08:46:00 -0800 (PST)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com. [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id ea10si4275597vdc.73.2015.01.09.08.45.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 09 Jan 2015 08:45:59 -0800 (PST)
Received: by mail-vc0-f170.google.com with SMTP id hy4so3501049vcb.1
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 08:45:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150108223024.da818218.akpm@linux-foundation.org>
References: <CAA25o9Sf62u3mJtBp_swLL0RS2Zb=EjZtWERJqyrbBpk7-bP-A@mail.gmail.com>
	<20150108223024.da818218.akpm@linux-foundation.org>
Date: Fri, 9 Jan 2015 08:45:59 -0800
Message-ID: <CAA25o9SQfb3yO2D4ABeeYoZkurhxramAgckr9DVOG1=DwVF0qg@mail.gmail.com>
Subject: Re: mm performance with zram
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

On Thu, Jan 8, 2015 at 10:30 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 8 Jan 2015 14:49:45 -0800 Luigi Semenzato <semenzato@google.com> wrote:
>
>> I am taking a closer look at the performance of the Linux MM in the
>> context of heavy zram usage.  The bottom line is that there is
>> surprisingly high overhead (35-40%) from MM code other than
>> compression/decompression routines.
>
> Those images hurt my eyes.

Sorry about that.  I didn't find other ways of computing the
cumulative cost of functions (i.e. time spent in a function and all
its descendants, like in gprof).  I couldn't get perf to do that
either.  A flat profile shows most functions take a fracion of 1%, so
it's not useful.  If anybody knows a better way I'll be glad to use
it.

> Did you work out where the time is being spent?

No, unfortunately it's difficult to make sense of the graph profile as
well, especially with my low familiarity with the code.  There is a
surprising number of different callers into the heaviest nodes and I
cannot tell which paths correspond to which high-level actions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
