Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id B8C006B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 01:14:56 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 1/2] mm: fincore()
In-Reply-To: <20130215154235.0fb36f53.akpm@linux-foundation.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au> <20130211162701.GB13218@cmpxchg.org> <20130211141239.f4decf03.akpm@linux-foundation.org> <20130215063450.GA24047@cmpxchg.org> <20130215132738.c85c9eda.akpm@linux-foundation.org> <20130215231304.GB23930@cmpxchg.org> <20130215154235.0fb36f53.akpm@linux-foundation.org>
Date: Mon, 18 Feb 2013 16:11:08 +1030
Message-ID: <87zjz2i3gr.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:
> The syscall should handle the common usages very well.  But it
> shouldn't handle uncommon usages very badly!

If the user is actually dealing with the contents of the file, following
the established mincore is preferred, since it's in the noise anyway.

Which comes back to needing a user; I'll see what I can come up with.

Cheers,
Rusty.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
