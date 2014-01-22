Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5417A6B0069
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 09:11:55 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id u57so358754wes.28
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:11:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id cm11si6786621wjb.17.2014.01.22.06.11.39
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 06:11:40 -0800 (PST)
Message-ID: <52DFD168.8080001@redhat.com>
Date: Wed, 22 Jan 2014 09:10:48 -0500
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] really large storage sectors - going
 beyond 4096 bytes
References: <20131220093022.GV11295@suse.de> <52DF353D.6050300@redhat.com> <20140122093435.GS4963@suse.de>
In-Reply-To: <20140122093435.GS4963@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 01/22/2014 04:34 AM, Mel Gorman wrote:
> On Tue, Jan 21, 2014 at 10:04:29PM -0500, Ric Wheeler wrote:
>> One topic that has been lurking forever at the edges is the current
>> 4k limitation for file system block sizes. Some devices in
>> production today and others coming soon have larger sectors and it
>> would be interesting to see if it is time to poke at this topic
>> again.
>>
> Large block support was proposed years ago by Christoph Lameter
> (http://lwn.net/Articles/232757/). I think I was just getting started
> in the community at the time so I do not recall any of the details. I do
> believe it motivated an alternative by Nick Piggin called fsblock though
> (http://lwn.net/Articles/321390/). At the very least it would be nice to
> know why neither were never merged for those of us that were not around
> at the time and who may not have the chance to dive through mailing list
> archives between now and March.
>
> FWIW, I would expect that a show-stopper for any proposal is requiring
> high-order allocations to succeed for the system to behave correctly.
>

I have a somewhat hazy memory of Andrew warning us that touching this code takes 
us into dark and scary places.

ric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
