Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE606B004D
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 16:47:23 -0400 (EDT)
Date: Wed, 9 Sep 2009 13:46:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-Id: <20090909134643.5479b09e.akpm@linux-foundation.org>
In-Reply-To: <20090907115430.6C16.A69D9226@jp.fujitsu.com>
References: <20090617132118.ef839ad7.akpm@linux-foundation.org>
	<20090618095705.99D2.A69D9226@jp.fujitsu.com>
	<20090907115430.6C16.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: hugh@veritas.com, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Mon,  7 Sep 2009 11:58:36 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Grr, my fault.
> > I recognize it. sorry.
> 
> I've finished my long pending homework ;)
> 
> Andrew, can you please replace following patch with getrusage-fill-ru_maxrss-value.patch
> and getrusage-fill-ru_maxrss-value-update.patch?
> 
> 
> 
> ChangeLog
>  ===============================
>   o Merge getrusage-fill-ru_maxrss-value.patch and getrusage-fill-ru_maxrss-value-update.patch
>   o rewrote test programs (older version hit FreeBSD bug and it obfuscate testcase intention, thanks Hugh)

The code changes are unaltered, so I merely updated the changelog.

The changelog had lots of ^------- lines in it.  But those are
conventionally the end-of-changelog separator so I rewrote them to
^=======

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
