Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A583E6B0037
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 16:27:07 -0400 (EDT)
Date: Tue, 18 Jun 2013 13:27:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] hugetlb fixes
Message-Id: <20130618132705.c5eb78a20499beb1b769f741@linux-foundation.org>
In-Reply-To: <20130618185055.GA27618@logfs.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
	<20130618185055.GA27618@logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 18 Jun 2013 14:50:55 -0400 J__rn Engel <joern@logfs.org> wrote:

> On Tue, 18 June 2013 14:47:03 -0400, Joern Engel wrote:
> > 
> > Test program below is failing before these two patches and passing
> > after.
> 
> Actually, do we have a place to stuff kernel tests?  And if not,
> should we have one?

Yep, tools/testing/selftests/vm.  It's pretty simple and stupid at
present - it anything about the framework irritates you, please fix it!

General guidelines for tools/testing/selftests: the tool should execute
quickly and shouldn't break the overall selftests run at either compile
time or runtime if kernel features are absent, Kconfig is unexpected,
etc.

It's more a "place to accumulate and maintain selftest programs" than a
serious self-testing framework.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
