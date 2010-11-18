Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 53BB46B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 12:41:40 -0500 (EST)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id oAIHfXQ4028706
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:41:35 -0800
Received: from qyk4 (qyk4.prod.google.com [10.241.83.132])
	by kpbe11.cbf.corp.google.com with ESMTP id oAIHfUF8015336
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:41:32 -0800
Received: by qyk4 with SMTP id 4so402069qyk.17
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:41:32 -0800 (PST)
Date: Thu, 18 Nov 2010 09:41:22 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mlock: avoid dirtying pages and triggering
 writeback
In-Reply-To: <20101118133702.GA18834@infradead.org>
Message-ID: <alpine.LSU.2.00.1011180934400.3210@tigran.mtv.corp.google.com>
References: <1289996638-21439-1-git-send-email-walken@google.com> <1289996638-21439-4-git-send-email-walken@google.com> <20101117125756.GA5576@amd> <1290007734.2109.941.camel@laptop> <AANLkTim4tO_aKzXLXJm-N-iEQ9rNSa0=HGJVDAz33kY6@mail.gmail.com>
 <20101117231143.GQ22876@dastard> <20101118133702.GA18834@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Theodore Tso <tytso@google.com>, Michael Rubin <mrubin@google.com>, Suleiman Souhlal <suleiman@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010, Christoph Hellwig wrote:
> On Thu, Nov 18, 2010 at 10:11:43AM +1100, Dave Chinner wrote:
> > Hence I think that avoiding ->page_mkwrite callouts is likely to
> > break some filesystems in subtle, undetected ways.  IMO, regardless
> > of what is done, it would be really good to start by writing a new
> > regression test to exercise and encode the expected the mlock
> > behaviour so we can detect regressions later on....
> 
> I think it would help if we could drink a bit of the test driven design
> coolaid here. Michel, can you write some testcases where pages on a
> shared mapping are mlocked, then dirtied and then munlocked, and then
> written out using msync/fsync.  Anything that fails this test on
> btrfs/ext4/gfs/xfs/etc obviously doesn't work.

Whilst it's hard to argue against a request for testing, Dave's worries
just sprang from a misunderstanding of all the talk about "avoiding ->
page_mkwrite".  There's nothing strange or risky about Michel's patch,
it does not avoid ->page_mkwrite when there is a write: it just stops
pretending that there was a write when locking down the shared area.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
