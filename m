Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 3BC186B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 19:22:49 -0400 (EDT)
Date: Tue, 11 Jun 2013 17:53:20 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH, RFC] mm: Implement RLIMIT_RSS
Message-ID: <20130611215319.GA29368@logfs.org>
References: <20130611182921.GB25941@logfs.org>
 <20130611211601.GA29426@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130611211601.GA29426@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 11 June 2013 17:16:01 -0400, Johannes Weiner wrote:
> On Tue, Jun 11, 2013 at 02:29:21PM -0400, JA?rn Engel wrote:
> > I've seen a couple of instances where people try to impose a vsize
> > limit simply because there is no rss limit in Linux.  The vsize limit
> > is a horrible approximation and even this patch seems to be an
> > improvement.
> > 
> > Would there be strong opposition to actually supporting RLIMIT_RSS?
> 
> This is trivial to exploit by creating the mappings first and
> populating them later, so while it may cover some use cases, it does
> not have the protection against malicious programs aspect that all the
> other rlimits have.

Hm.  The use case I have is that an application wants to limit itself.
It is effectively a special assert to catch memory leaks and the like.
So malicious programs are not my immediate concern.

Of course the moment Linux supports RLIMIT_RSS people will use it to
limit malicious programs, no matter how many scary warning we put in.

> The right place to enforce the limit is at the point of memory
> allocation, which raises the question what to do when the limit is
> exceeded in a page fault.  Reclaim from the process's memory?  Kill
> it?
> 
> I guess the answer to these questions is "memory cgroups", so that's
> why there is no real motivation to implement RLIMIT_RSS separately...

Lack of opposition would be enough for me.  But I guess we need a bit
more for a mergeable patch than I did and I only did the existing
patch because it seemed easy, not because it is important.  Will keep
the patch in my junk code folder for now.

JA?rn

--
A surrounded army must be given a way out.
-- Sun Tzu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
