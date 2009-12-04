Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5F4F56B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 13:53:09 -0500 (EST)
Date: Fri, 4 Dec 2009 19:53:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091204185303.GL28697@random.random>
References: <20091202125501.GD28697@random.random>
 <20091203134610.586E.A69D9226@jp.fujitsu.com>
 <20091204135938.5886.A69D9226@jp.fujitsu.com>
 <20091204141617.f4c491e7.kamezawa.hiroyu@jp.fujitsu.com>
 <20091204171640.GE19624@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091204171640.GE19624@x200.localdomain>
Sender: owner-linux-mm@kvack.org
To: Chris Wright <chrisw@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 04, 2009 at 09:16:40AM -0800, Chris Wright wrote:
> That's why I mentioned the page of zeroes as the prime example of
> something with a high mapcount that shouldn't really ever be evicted.

Just a nitpick, "never" is too much, it should remain evictable if
somebody halts all VM from monitor and starts a workloads that fills
RAM and runs for a very prolonged time pushing all VM into swap. This
is especially true if we stick to the below approach and it isn't
just 1 page in high-sharing.

> It's a somewhat special case, but wouldn't it be useful to have a generic
> method to recognize this kind of sharing since it's a generic issue?

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
