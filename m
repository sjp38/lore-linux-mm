Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id D443B6B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 04:57:32 -0400 (EDT)
Date: Thu, 13 Jun 2013 17:57:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH, RFC] mm: Implement RLIMIT_RSS
Message-ID: <20130613085732.GB4533@bbox>
References: <20130611182921.GB25941@logfs.org>
 <20130611211601.GA29426@cmpxchg.org>
 <20130611215319.GA29368@logfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20130611215319.GA29368@logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hey Jorn,

On Tue, Jun 11, 2013 at 05:53:20PM -0400, Jorn Engel wrote:
> On Tue, 11 June 2013 17:16:01 -0400, Johannes Weiner wrote:
> > On Tue, Jun 11, 2013 at 02:29:21PM -0400, Jorn Engel wrote:
> > > I've seen a couple of instances where people try to impose a vsize
> > > limit simply because there is no rss limit in Linux.  The vsize limit
> > > is a horrible approximation and even this patch seems to be an
> > > improvement.
> > > 
> > > Would there be strong opposition to actually supporting RLIMIT_RSS?
> > 
> > This is trivial to exploit by creating the mappings first and
> > populating them later, so while it may cover some use cases, it does
> > not have the protection against malicious programs aspect that all the
> > other rlimits have.
> 
> Hm.  The use case I have is that an application wants to limit itself.
> It is effectively a special assert to catch memory leaks and the like.
> So malicious programs are not my immediate concern.

Just out of curisoity.

It means you already know the max rss of the application in advance
so you can use taskstats's hiwater_rss if you don't need to catch
the moment which rss is over the limit.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
