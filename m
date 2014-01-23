Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0ED006B0031
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 15:47:14 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id e11so645772bkh.25
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 12:47:14 -0800 (PST)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id no1si18495bkb.312.2014.01.23.12.47.12
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 12:47:13 -0800 (PST)
Date: Thu, 23 Jan 2014 14:47:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
In-Reply-To: <20140122093435.GS4963@suse.de>
Message-ID: <alpine.DEB.2.10.1401231436300.8031@nuc>
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com> <20140122093435.GS4963@suse.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ric Wheeler <rwheeler@redhat.com>, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Wed, 22 Jan 2014, Mel Gorman wrote:

> Large block support was proposed years ago by Christoph Lameter
> (http://lwn.net/Articles/232757/). I think I was just getting started
> in the community at the time so I do not recall any of the details. I do
> believe it motivated an alternative by Nick Piggin called fsblock though
> (http://lwn.net/Articles/321390/). At the very least it would be nice to
> know why neither were never merged for those of us that were not around
> at the time and who may not have the chance to dive through mailing list
> archives between now and March.

It was rejected first because of the necessity of higher order page
allocations. Nick and I then added ways to virtually map higher order
pages if the page allocator could no longe provide those.

All of this required changes to the basic page cache operations. I added a
way for the mapping to indicate an order for an address range and then
modified the page cache operations to be able to operate on any order
pages.

The patchset that introduced the ability to specify different orders for
the pagecache address ranges was not accepted by Andrew because he thought
there was no chance for the rest of the modifications to become
acceptable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
