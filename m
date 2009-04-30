Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2007E6B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 09:08:19 -0400 (EDT)
Message-ID: <49F9A2B6.6070801@redhat.com>
Date: Thu, 30 Apr 2009 09:08:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
References: <20090428044426.GA5035@eskimo.com> <20090428192907.556f3a34@bree.surriel.com> <1240987349.4512.18.camel@laptop> <20090429114708.66114c03@cuia.bos.redhat.com> <20090430072057.GA4663@eskimo.com>
In-Reply-To: <20090430072057.GA4663@eskimo.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Elladan <elladan@eskimo.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Elladan wrote:

>> Elladan, does this smaller patch still work as expected?

> The system does seem relatively responsive with this patch for the most part,
> with occasional lag.  I don't see much evidence at least over the course of a
> few minutes that it pages out applications significantly.  It seems about
> equivalent to the first patch.

OK, good to hear that.

> This seems ok (not disastrous, anyway).  I suspect desktop users would
> generally prefer the VM were extremely aggressive about keeping their
> executables paged in though, 

I agree that desktop users would probably prefer something even
more aggressive.  However, we do need to balance this against
other workloads, where inactive file pages need to be given a
fair chance to be referenced twice and promoted to the active
file list.

Because of that, I have chosen a patch with a minimal risk of
regressions on any workload.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
