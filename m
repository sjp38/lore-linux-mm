Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 356886B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 19:33:02 -0400 (EDT)
Date: Wed, 9 Sep 2009 16:32:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-Id: <20090909163212.11464d64.akpm@linux-foundation.org>
In-Reply-To: <20090910081020.9CAE.A69D9226@jp.fujitsu.com>
References: <20090907115430.6C16.A69D9226@jp.fujitsu.com>
	<20090909134643.5479b09e.akpm@linux-foundation.org>
	<20090910081020.9CAE.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: hugh@veritas.com, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Thu, 10 Sep 2009 08:17:27 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> > The changelog had lots of ^------- lines in it.  But those are
> > conventionally the end-of-changelog separator so I rewrote them to
> > ^=======
> 
> sorry, I have stupid question.
> I thought "--" and "---" have special meaning. but other length "-" are safe.
> Is this incorrect?
> 
> or You mean it's easy confusing bad style?

Ideally, ^---$ is the only pattern we need to worry about.

In the real world, ^-------- might trigger people's sloppy scripts so
it's best to be safe and avoid it altogether.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
