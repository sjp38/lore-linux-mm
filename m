Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03F906B0007
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 18:46:12 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w10so11829009wrg.2
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 15:46:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q127si6182139wma.6.2018.02.13.15.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 15:46:10 -0800 (PST)
Date: Tue, 13 Feb 2018 15:46:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore
 for percent
Message-Id: <20180213154607.f631e2e033f42c32925e3d2d@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On Mon, 12 Feb 2018 16:24:25 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> Both kernelcore= and movablecore= can be used to define the amount of
> ZONE_NORMAL and ZONE_MOVABLE on a system, respectively.  This requires
> the system memory capacity to be known when specifying the command line,
> however.
> 
> This introduces the ability to define both kernelcore= and movablecore=
> as a percentage of total system memory.  This is convenient for systems
> software that wants to define the amount of ZONE_MOVABLE, for example, as
> a proportion of a system's memory rather than a hardcoded byte value.
> 
> To define the percentage, the final character of the parameter should be
> a '%'.

Is this fine-grained enough?  We've had percentage-based tunables in
the past, and 10 years later when systems are vastly larger, 1% is too
much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
