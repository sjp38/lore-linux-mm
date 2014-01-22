Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id C665A6B0037
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 10:19:17 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so4937924eei.7
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 07:19:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si18053774eeh.136.2014.01.22.07.19.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 07:19:16 -0800 (PST)
Date: Wed, 22 Jan 2014 15:19:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
Message-ID: <20140122151913.GY4963@suse.de>
References: <20131220093022.GV11295@suse.de>
 <52DF353D.6050300@redhat.com>
 <20140122093435.GS4963@suse.de>
 <52DFD168.8080001@redhat.com>
 <20140122143452.GW4963@suse.de>
 <52DFDCA6.1050204@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52DFDCA6.1050204@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 22, 2014 at 09:58:46AM -0500, Ric Wheeler wrote:
> On 01/22/2014 09:34 AM, Mel Gorman wrote:
> >On Wed, Jan 22, 2014 at 09:10:48AM -0500, Ric Wheeler wrote:
> >>On 01/22/2014 04:34 AM, Mel Gorman wrote:
> >>>On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
> >>>>One topic that has been lurking forever at the edges is the current
> >>>>4k limitation for file system block sizes. Some devices in
> >>>>production today and others coming soon have larger sectors and it
> >>>>would be interesting to see if it is time to poke at this topic
> >>>>again.
> >>>>
> >>>Large block support was proposed years ago by Christoph Lameter
> >>>(http://lwn.net/Articles/232757/). I think I was just getting started
> >>>in the community at the time so I do not recall any of the details. I do
> >>>believe it motivated an alternative by Nick Piggin called fsblock though
> >>>(http://lwn.net/Articles/321390/). At the very least it would be nice to
> >>>know why neither were never merged for those of us that were not around
> >>>at the time and who may not have the chance to dive through mailing list
> >>>archives between now and March.
> >>>
> >>>FWIW, I would expect that a show-stopper for any proposal is requiring
> >>>high-order allocations to succeed for the system to behave correctly.
> >>>
> >>I have a somewhat hazy memory of Andrew warning us that touching
> >>this code takes us into dark and scary places.
> >>
> >That is a light summary. As Andrew tends to reject patches with poor
> >documentation in case we forget the details in 6 months, I'm going to guess
> >that he does not remember the details of a discussion from 7ish years ago.
> >This is where Andrew swoops in with a dazzling display of his eidetic
> >memory just to prove me wrong.
> >
> >Ric, are there any storage vendor that is pushing for this right now?
> >Is someone working on this right now or planning to? If they are, have they
> >looked into the history of fsblock (Nick) and large block support (Christoph)
> >to see if they are candidates for forward porting or reimplementation?
> >I ask because without that person there is a risk that the discussion
> >will go as follows
> >
> >Topic leader: Does anyone have an objection to supporting larger block
> >	sizes than the page size?
> >Room: Send patches and we'll talk.
> >
> 
> I will have to see if I can get a storage vendor to make a public
> statement, but there are vendors hoping to see this land in Linux in
> the next few years.

What about the second and third questions -- is someone working on this
right now or planning to? Have they looked into the history of fsblock
(Nick) and large block support (Christoph) to see if they are candidates
for forward porting or reimplementation?

Don't get me wrong, I'm interested in the topic but I severely doubt I'd
have the capacity to research the background of this in advance. It's also
unlikely that I'd work on it in the future without throwing out my current
TODO list. In an ideal world someone will have done the legwork in advance
of LSF/MM to help drive the topic.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
