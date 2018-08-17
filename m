Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C85DF6B08B5
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 10:46:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g11-v6so3146686edi.8
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 07:46:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y19-v6si3104842edm.267.2018.08.17.07.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 07:46:44 -0700 (PDT)
Date: Fri, 17 Aug 2018 16:46:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-ID: <20180817144642.GC709@dhcp22.suse.cz>
References: <1978465524.8206495.1534505385491.ref@mail.yahoo.com>
 <1978465524.8206495.1534505385491@mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1978465524.8206495.1534505385491@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry <reserv0@yahoo.com>
Cc: Alkis Georgopoulos <alkisg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>

On Fri 17-08-18 11:29:45, Thierry wrote:
> On Fri, 8/17/18, Michal Hocko <mhocko@kernel.org> wrote:
> 
> > Have you tried to set highmem_is_dirtyable as suggested elsewhere?
> 
> I tried everything, and yes, that too, to no avail. The only solution is to limit the
> available RAM to less than 12Gb, which is just unacceptable for me.
>  
> > I would like to stress out that 16GB with 32b kernels doesn't play really nice.
> 
> I would like to stress out that 32 Gb of RAM played totally nice and very smoothly
> with v4.1 and older kernels... This got broken in v4.2 and never repaired since.
> This is a very nasty regression, and my suggestion to keep v4.1 maintained till
> that regression would finally get worked around fell into deaf ears...
> 
> > Even small changes (larger kernel memory footprint) can lead to all sorts of
> > problems. I would really recommend using 64b kernels instead. There shouldn't be
> > any real reason to stick with 32bhighmem based  kernel for such a large beast.
> > I strongly doubt the cpu itself would be 32b only.
> 
> The reasons are many (one of them dealing with being able to run old 32 bits
> Linux distros but without the bugs and security flaws of old, unmaintained kernels).

You can easily run 32b distribution on top of 64b kernels.

> But the reasons are not the problem here. The problem is that v4.2 introduced a
> bug (*) that was never fixed since.
> 
> A shame, really. :-(

Well. I guess nobody is disputing this is really annoying. I do
agree! On the other nobody came up with an acceptable solution. I would
love to dive into solving this but there are so many other things to
work on with much higher priority. Really, my todo list is huge and
growing. 32b kernels with that much memory is simply not all that high
on that list because there is a clear possibility of running 64b kernel
on the hardware which supports.

I fully understand your frustration and feel sorry about that but we are
only so many of us working on this subsystem. If you are willing to dive
into this then by all means. I am pretty sure you will find a word of
help and support but be warned this is not really trivial.

good luck
-- 
Michal Hocko
SUSE Labs
