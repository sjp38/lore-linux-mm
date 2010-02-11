Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A8F56B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:07:46 -0500 (EST)
Date: Thu, 11 Feb 2010 14:07:18 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] mm: suppress pfn range output for zones without pages
In-Reply-To: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1002111406110.7201@router.home>
References: <alpine.DEB.2.00.1002110129280.3069@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Feb 2010, David Rientjes wrote:

> The output is now suppressed for zones that do not have a valid pfn
> range.

There is a difference between zone support not compiled into the kernel
and the zone being empty. The output so far allows me to see that support
for a zone was compiled into the kernel but it is empty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
