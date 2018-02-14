Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85A4F6B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 20:14:36 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 30so11850732wrw.6
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 17:14:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p26si5660415wmc.40.2018.02.13.17.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 17:14:35 -0800 (PST)
Date: Tue, 13 Feb 2018 17:14:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-Id: <20180213171432.13c496c6603255bff66ce826@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1802131550210.130394@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
	<20180213154607.f631e2e033f42c32925e3d2d@linux-foundation.org>
	<alpine.DEB.2.10.1802131550210.130394@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Tue, 13 Feb 2018 15:55:11 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> > 
> > Is this fine-grained enough?  We've had percentage-based tunables in
> > the past, and 10 years later when systems are vastly larger, 1% is too
> > much.
> > 
> 
> They still have the (current) ability to define the exact amount of bytes 
> down to page sized granularity, whereas 1% would yield 40GB on a 4TB 
> system.  I'm not sure that people will want any finer-grained control if 
> defining the proportion of the system for kernelcore.  They do have the 
> ability with the existing interface, though, if they want to be that 
> precise.
> 
> (This is a cop out for not implementing some fractional percentage parser, 
>  although that would be possible as a more complete solution.)

And the interface which you've proposed can be seamlessly extended to
accept 0.07%, so not a problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
