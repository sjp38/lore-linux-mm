Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8846B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 03:55:20 -0400 (EDT)
Date: Sat, 11 Jun 2011 03:55:16 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] REPOST: Memory tracking for physical machine migration
Message-ID: <20110611075516.GA7745@infradead.org>
References: <20110610231850.6327.24452.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610231850.6327.24452.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jim Paradis <james.paradis@stratus.com>
Cc: linux-mm@kvack.org

On Fri, Jun 10, 2011 at 07:19:06PM -0400, Jim Paradis wrote:
> [tried posting this a couple days ago... kept having formatting problems
> with the exchange server.  Let's see how this works...]

Much more important is the problem that the patch is utterly useless
as-is.  It just adds adds exports, but no real functionality.  It's not
like I have told you exactly that a million times before, but given that
you don't want to listen it might just be easier to ignore your patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
