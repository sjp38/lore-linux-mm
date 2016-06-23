Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE039828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 12:39:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so29466214wme.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:39:13 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id h204si1948017wmh.97.2016.06.23.09.39.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 09:39:12 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 8D9AE98B2E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 16:39:12 +0000 (UTC)
Date: Thu, 23 Jun 2016 17:39:10 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC, DEBUGGING 1/2] mm: pass NR_FILE_PAGES/NR_SHMEM into
 node_page_state
Message-ID: <20160623163910.GB1868@techsingularity.net>
References: <20160623100518.156662-1-arnd@arndb.de>
 <3817461.6pThRKgN9N@wuerfel>
 <20160623135111.GX1868@techsingularity.net>
 <4149446.1SMXVuGq6X@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4149446.1SMXVuGq6X@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 23, 2016 at 05:56:57PM +0200, Arnd Bergmann wrote:
> On Thursday, June 23, 2016 2:51:11 PM CEST Mel Gorman wrote:
> > On Thu, Jun 23, 2016 at 03:17:43PM +0200, Arnd Bergmann wrote:
> > > > I have an alternative fix for this in a private tree. For now, I've asked
> > > > Andrew to withdraw the series entirely as there are non-trivial collisions
> > > > with OOM detection rework and huge page support for tmpfs.  It'll be easier
> > > > and safer to resolve this outside of mmotm as it'll require a full round
> > > > of testing which takes 3-4 days.
> > > 
> > > Ok. I've done a new version of my debug patch now, will follow up here
> > > so you can do some testing on top of that as well if you like. We probably
> > > don't want to apply my patch for the type checking, but you might find it
> > > useful for your own testing.
> > > 
> > 
> > It is useful. After fixing up a bunch of problems manually, it
> > identified two more errors. I probably won't merge it but I'll hang on
> > to it during development.
> 
> I'm glad it helps. On my randconfig build machine, I've also now run
> into yet another finding that I originally didn't catch, not sure if you
> found this one already:
> 

It's corrected in my current working tree. Thanks for continuing to
check.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
