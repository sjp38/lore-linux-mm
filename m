Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C93C46002CC
	for <linux-mm@kvack.org>; Fri, 21 May 2010 02:17:54 -0400 (EDT)
Date: Thu, 20 May 2010 23:18:03 -0700 (PDT)
Message-Id: <20100520.231803.168054302.davem@davemloft.net>
Subject: Re: RFC: dirty_ratio back to 40%
From: David Miller <davem@davemloft.net>
In-Reply-To: <4BF51B0A.1050901@redhat.com>
References: <4BF51B0A.1050901@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Larry Woodman <lwoodman@redhat.com>
Date: Thu, 20 May 2010 07:20:42 -0400

> Increasing the dirty_ratio to 40% will regain the performance loss
> seen in several benchmarks.  Whats everyone think about this???

I've been making this change via sysctl on every single system I have,
and have been doing so for quite some time.

When doing a lot of GIT operations to a non-SSD disk the kernel simply
can't submit the writes early enough to prevent everything getting
backlogged, and then processes pile up being forced to sleep on I/O
for several seconds at a time.

I therefore totally support making this the default, but I know some
people will be against it :-)

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
