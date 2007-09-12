Date: Wed, 12 Sep 2007 13:52:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 13 of 24] simplify oom heuristics
Message-Id: <20070912135231.43e8388c.akpm@linux-foundation.org>
In-Reply-To: <20070912134012.GL21600@v2.random>
References: <patchbomb.1187786927@v2.random>
	<cd70d64570b9add8072f.1187786940@v2.random>
	<20070912055240.cb60aeb4.akpm@linux-foundation.org>
	<20070912134012.GL21600@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 15:40:12 +0200 Andrea Arcangeli <andrea@suse.de> wrote:

> On Wed, Sep 12, 2007 at 05:52:40AM -0700, Andrew Morton wrote:
> > I think the idea behind the code which you're removing is to avoid killing
> > a computationally-expensive task which we've already invested a lot of CPU
> > time in.  IOW, kill the job which has been running for three seconds in
> > preference to the one which has been running three weeks.
> > 
> > That seems like a good strategy to me.
> 
> I know... but for certain apps like simulations, the task that goes
> oom is one of the longest running ones.

hmm.  There are ways in which operators can tweak this manually, aren't there?
I'd expect that owners of large, computationally expensive tasks which tend to go
oom are the sorts of people who would actually bother to learn about and alter
the kernel defaults.

Perhaps we aren't giving them sufficient controls at present?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
