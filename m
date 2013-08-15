Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 696736B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 05:25:17 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id k13so366788wgh.25
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 02:25:15 -0700 (PDT)
Message-ID: <520C9E78.2020401@gmail.com>
Date: Thu, 15 Aug 2013 11:25:12 +0200
From: Ben Tebulin <tebulin@googlemail.com>
MIME-Version: 1.0
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert
 53a59fc67!
References: <52050382.9060802@gmail.com> <520BB225.8030807@gmail.com> <20130814174039.GA24033@dhcp22.suse.cz> <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com> <20130814182756.GD24033@dhcp22.suse.cz> <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
In-Reply-To: <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

Am 14.08.2013 20:35, schrieb Linus Torvalds:
> Yes, the bug was originally introduced in 597e1c35, but in practice it
> never happened, [...]
> 
> NOTE! I still absolutely want Ben to actually test that fix (ie
> backport commit e6c495a96ce0 to his tree), because without testing
> this is all just theoretical, and there might be other things hiding
> here.[..]

I just cherry-picked e6c495a96ce0 into 3.9.11 and 3.7.10.
Unfortunately this does _not resolve_ my issue (too good to be true) :-(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
