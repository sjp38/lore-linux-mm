Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 913DD6B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 10:00:29 -0400 (EDT)
Date: Thu, 30 Apr 2009 07:00:16 -0700
From: Elladan <elladan@eskimo.com>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-ID: <20090430140016.GB31807@eskimo.com>
References: <20090428044426.GA5035@eskimo.com> <20090428192907.556f3a34@bree.surriel.com> <1240987349.4512.18.camel@laptop> <20090429114708.66114c03@cuia.bos.redhat.com> <20090430072057.GA4663@eskimo.com> <49F9A2B6.6070801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49F9A2B6.6070801@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Elladan <elladan@eskimo.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 30, 2009 at 09:08:06AM -0400, Rik van Riel wrote:
> Elladan wrote:
>
>>> Elladan, does this smaller patch still work as expected?
>
>> The system does seem relatively responsive with this patch for the most part,
>> with occasional lag.  I don't see much evidence at least over the course of a
>> few minutes that it pages out applications significantly.  It seems about
>> equivalent to the first patch.
>
> OK, good to hear that.
>
>> This seems ok (not disastrous, anyway).  I suspect desktop users would
>> generally prefer the VM were extremely aggressive about keeping their
>> executables paged in though, 
>
> I agree that desktop users would probably prefer something even
> more aggressive.  However, we do need to balance this against
> other workloads, where inactive file pages need to be given a
> fair chance to be referenced twice and promoted to the active
> file list.
>
> Because of that, I have chosen a patch with a minimal risk of
> regressions on any workload.

I agree, this seems to work well as a bugfix, for a general purpose system.

I'm just not sure that a general-purpose page replacement algorithm actually
serves most desktop users well.  I remember using some kludges back in the
2.2/2.4 days to try to force eviction of application pages when my system was
low on ram on occasion, but for desktop use that naive VM actually seemed
to generally have fewer latency problems.

Plus, since hard disks haven't been improving in speed (except for the surge in
SSDs), but RAM and CPU have been increasing dramatically, any paging or
swapping activity just becomes more and more noticeable.

Thanks,
Elladan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
