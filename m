Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B33C6B0092
	for <linux-mm@kvack.org>; Mon,  4 May 2009 07:08:46 -0400 (EDT)
Date: Mon, 4 May 2009 07:08:41 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 3/3] mm: introduce follow_pfn()
Message-ID: <20090504110841.GA19646@infradead.org>
References: <20090501181449.GA8912@cmpxchg.org> <1241430874-12667-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1241430874-12667-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Magnus Damm <magnus.damm@gmail.com>, linux-media@vger.kernel.org, Hans Verkuil <hverkuil@xs4all.nl>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 04, 2009 at 11:54:34AM +0200, Johannes Weiner wrote:
> Analoguous to follow_phys(), add a helper that looks up the PFN
> instead.  It also only allows IO mappings or PFN mappings.

A kerneldoc describing what it does and the limitations would be
extremly helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
