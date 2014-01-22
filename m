Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id BB57C6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:34:40 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id a1so113427wgh.16
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 01:34:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cs3si6015237wjc.60.2014.01.22.01.34.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 01:34:39 -0800 (PST)
Date: Wed, 22 Jan 2014 09:34:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140122093435.GS4963@suse.de>
References: <20131220093022.GV11295@suse.de>
 <52DF353D.6050300@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52DF353D.6050300@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org

On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
> One topic that has been lurking forever at the edges is the current
> 4k limitation for file system block sizes. Some devices in
> production today and others coming soon have larger sectors and it
> would be interesting to see if it is time to poke at this topic
> again.
> 

Large block support was proposed years ago by Christoph Lameter
(http://lwn.net/Articles/232757/). I think I was just getting started
in the community at the time so I do not recall any of the details. I do
believe it motivated an alternative by Nick Piggin called fsblock though
(http://lwn.net/Articles/321390/). At the very least it would be nice to
know why neither were never merged for those of us that were not around
at the time and who may not have the chance to dive through mailing list
archives between now and March.

FWIW, I would expect that a show-stopper for any proposal is requiring
high-order allocations to succeed for the system to behave correctly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
