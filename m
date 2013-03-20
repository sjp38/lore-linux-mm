Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BFFDC6B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 16:56:20 -0400 (EDT)
Date: Wed, 20 Mar 2013 13:56:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4 v3]swap: make cluster allocation per-cpu
Message-Id: <20130320135618.a476f40e4683cf20509b904d@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1303191540220.5966@eggly.anvils>
References: <20130221021858.GD32580@kernel.org>
	<alpine.LNX.2.00.1303191540220.5966@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, linux-mm@kvack.org

On Tue, 19 Mar 2013 16:09:01 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> But I'm not all that keen on this one.  Partly because I suspect that
> this per-cpu'ing won't in the end be the right approach

That was my reaction.  The CPU isn't the logical thing upon which to
key the clustering.  It mostly-works, because of the way in which the
kernel operates but it's a bit of a flukey hack.  A more logical thing
around which to subdivide the clustering is the mm_struct.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
