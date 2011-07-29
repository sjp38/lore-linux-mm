Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 84CBA6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 09:42:24 -0400 (EDT)
Received: by pzk33 with SMTP id 33so6676151pzk.36
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 06:42:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110729095005.GH1843@barrios-desktop>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <20110727161821.GA1738@barrios-desktop> <20110728113852.GN3010@suse.de>
 <20110729094816.GG1843@barrios-desktop> <20110729095005.GH1843@barrios-desktop>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 29 Jul 2011 09:41:59 -0400
Message-ID: <CAObL_7Fnc820gFvFxZa3iHUzkKaZaMy9o7LAN7z8mk8_zUxkrQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Fri, Jul 29, 2011 at 5:50 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Sorry for missing Ccing.
>
> On Fri, Jul 29, 2011 at 06:48:16PM +0900, Minchan Kim wrote:
>> On Thu, Jul 28, 2011 at 12:38:52PM +0100, Mel Gorman wrote:
>> > On Thu, Jul 28, 2011 at 01:18:21AM +0900, Minchan Kim wrote:
>> > > On Thu, Jul 21, 2011 at 05:28:42PM +0100, Mel Gorman wrote:
>> > > > Note how preventing kswapd reclaiming dirty pages pushes up its CPU
>>
>> <snip>
>>
>> > > > usage as it scans more pages but it does not get excessive due to
>> > > > the throttling.
>> > >
>> > > Good to hear.
>> > > The concern of this patchset was early OOM kill with too many scanning.
>> > > I can throw such concern out from now on.
>> > >
>> >
>> > At least, I haven't been able to trigger a premature OOM.
>>
>> AFAIR, Andrew had a premature OOM problem[1] but I couldn't track down at that time.
>> I think this patch series might solve his problem. Although it doesn't, it should not accelerate
>> his problem, at least.
>>
>> Andrew, Could you test this patchset?

Gladly, but not until Wednesday most likely.  I'm defending my thesis
on Monday :)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
