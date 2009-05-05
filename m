Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 94B3E6B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 15:29:09 -0400 (EDT)
Date: Tue, 5 May 2009 12:24:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/3] mm: introduce follow_pte()
Message-Id: <20090505122442.6271c7da.akpm@linux-foundation.org>
In-Reply-To: <1241430874-12667-1-git-send-email-hannes@cmpxchg.org>
References: <20090501181449.GA8912@cmpxchg.org>
	<1241430874-12667-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: magnus.damm@gmail.com, linux-media@vger.kernel.org, hverkuil@xs4all.nl, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon,  4 May 2009 11:54:32 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> A generic readonly page table lookup helper to map an address space
> and an address from it to a pte.

umm, OK.

Is there actually some point to these three patches?  If so, what is it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
