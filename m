Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id AA9966B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 10:38:18 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so1157273pab.31
        for <linux-mm@kvack.org>; Thu, 15 May 2014 07:38:18 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id vv4si2791067pbc.21.2014.05.15.07.38.17
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 07:38:17 -0700 (PDT)
Date: Thu, 15 May 2014 07:38:05 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] HWPOISON: avoid repeatedly raising some MCEs for a
 shared page
Message-ID: <20140515143805.GB19657@tassilo.jf.intel.com>
References: <1400152576-32004-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1400152576-32004-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: fengguang.wu@intel.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org

On Thu, May 15, 2014 at 07:16:16PM +0800, Chen Yucong wrote:
> We assume that there have three processes P1, P2, and P3 which share a
> page frame PF0. PF0 have a multi-bit error that has not yet been detected.

How likely is that? Did you see it in some real case?

> As
> a result, P1/P2 may raise the same MCE again.

And how is that a problem?

The memory error handling is always somewhat probabilistic. There are a 
lot of corner cases that could be be handled, but it would
be even more complex than it already is, and most of them are unlikely
to happen. The more complexity the more risk of unintended bugs.

So the question is always how likely that case is, and is it worth
handling. It's far better to focus on the common case.

Another concern is always how to test this. Usually all explicit paths
should have test cases in mce-test.

But it's not clear to me the additional complexity here is justified.

-andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
