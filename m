Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D0116B003D
	for <linux-mm@kvack.org>; Sat,  7 Feb 2009 12:24:33 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
Date: Sat, 7 Feb 2009 18:23:53 +0100
References: <20090206031125.693559239@cmpxchg.org> <20090206130009.99400d43.akpm@linux-foundation.org> <20090206232747.GA3539@cmpxchg.org>
In-Reply-To: <20090206232747.GA3539@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902071823.54259.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 07 February 2009, Johannes Weiner wrote:
> On Fri, Feb 06, 2009 at 01:00:09PM -0800, Andrew Morton wrote:
> > On Fri, 6 Feb 2009 05:49:07 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > > and, I think you should mesure performence result.
> > > 
> > > Yes, I'm still thinking about ideas how to quantify it properly.  I
> > > have not yet found a reliable way to check for whether the working set
> > > is intact besides seeing whether the resumed applications are
> > > responsive right away or if they first have to swap in their pages
> > > again.
> > 
> > Describing your subjective non-quantitative impressions would be better
> > than nothing...
> 
> Okay.
> 
> > The patch bugs me.
> 
> Please ignore it, it is broken as is.  My verbal cortex got obviously
> disconnected from my code cortex when writing the changelog...

If I understood this correctly, patch 3/3 is to be disregarded.

> And I will reconsider the actual change bits, I still think that we
> shouldn't scan anon page lists while may_swap is zero.

Hm, can you please remind me what may_swap == 0 acutally means?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
