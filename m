Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3860C6B0007
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 18:55:14 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id c1so1139447iob.18
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 15:55:14 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y9sor6975431itb.58.2018.02.13.15.55.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Feb 2018 15:55:13 -0800 (PST)
Date: Tue, 13 Feb 2018 15:55:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
In-Reply-To: <20180213154607.f631e2e033f42c32925e3d2d@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1802131550210.130394@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com> <20180213154607.f631e2e033f42c32925e3d2d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Tue, 13 Feb 2018, Andrew Morton wrote:

> > Both kernelcore= and movablecore= can be used to define the amount of
> > ZONE_NORMAL and ZONE_MOVABLE on a system, respectively.  This requires
> > the system memory capacity to be known when specifying the command line,
> > however.
> > 
> > This introduces the ability to define both kernelcore= and movablecore=
> > as a percentage of total system memory.  This is convenient for systems
> > software that wants to define the amount of ZONE_MOVABLE, for example, as
> > a proportion of a system's memory rather than a hardcoded byte value.
> > 
> > To define the percentage, the final character of the parameter should be
> > a '%'.
> 
> Is this fine-grained enough?  We've had percentage-based tunables in
> the past, and 10 years later when systems are vastly larger, 1% is too
> much.
> 

They still have the (current) ability to define the exact amount of bytes 
down to page sized granularity, whereas 1% would yield 40GB on a 4TB 
system.  I'm not sure that people will want any finer-grained control if 
defining the proportion of the system for kernelcore.  They do have the 
ability with the existing interface, though, if they want to be that 
precise.

(This is a cop out for not implementing some fractional percentage parser, 
 although that would be possible as a more complete solution.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
