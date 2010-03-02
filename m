Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D73456B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 18:49:31 -0500 (EST)
Date: Tue, 2 Mar 2010 15:48:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
 allocators
Message-Id: <20100302154821.5aed96b1.akpm@linux-foundation.org>
In-Reply-To: <20100301135242.GE3852@csn.ul.ie>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com>
	<20100301135242.GE3852@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Mar 2010 13:52:42 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> I'm not against it as such, but I'd like to know more about the problem
> this solves and what the before and after behaviour looks like.


^^ this

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
