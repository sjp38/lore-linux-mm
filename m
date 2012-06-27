Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 3C9ED6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 02:40:16 -0400 (EDT)
Date: Tue, 26 Jun 2012 23:41:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: needed lru_add_drain_all() change
Message-Id: <20120626234119.755af455.akpm@linux-foundation.org>
In-Reply-To: <4FEAA925.9020202@kernel.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
	<4FEA59EE.8060804@kernel.org>
	<20120626181504.23b8b73d.akpm@linux-foundation.org>
	<4FEA6B5B.5000205@kernel.org>
	<20120626221217.1682572a.akpm@linux-foundation.org>
	<4FEA9D13.6070409@kernel.org>
	<20120626225544.068df1b9.akpm@linux-foundation.org>
	<4FEAA925.9020202@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, 27 Jun 2012 15:33:09 +0900 Minchan Kim <minchan@kernel.org> wrote:

> Anyway, let's wait further answer, especially, RT folks. 

rt folks said "it isn't changing", and I agree with them.  It isn't
worth breaking the rt-prio quality of service because a few odd parts
of the kernel did something inappropriate.  Especially when those
few sites have alternatives.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
