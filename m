Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CDB076B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 04:01:40 -0400 (EDT)
Date: Fri, 5 Aug 2011 09:01:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MMTests 0.01
Message-ID: <20110805080133.GS19099@suse.de>
References: <20110804143844.GQ19099@suse.de>
 <1312526302.37390.YahooMailNeo@web162009.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1312526302.37390.YahooMailNeo@web162009.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Agarwal <pintu_agarwal@yahoo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Aug 04, 2011 at 11:38:22PM -0700, Pintu Agarwal wrote:
> Dear Mel Gorman,
>  
> Thank you very much for this MMTest. 
> It will be very helpful for me for all my needs.
> I was looking forward for these kind of mm test utilities.
>  
> Just wanted to know, if any of these utilities also covers
> anti-fragmentation represent of the various page state in the form
> of jpeg image?

No, that particular script was not included as it needs a kernel patch
to be really useful and depends on parts of VM Regress that were very
ugly. As I've said before, I generally use unusable free space index
and fragmentation index if I'm trying to graph fragmentation-related
information. To record it, I use the "extfrag" monitor in monitors/
. It uses other helpers of which fraganalysis/show-buddyinfo is the
most important as it is the one that can read either /proc/buddyinfo
or use /proc/kpagefrags to build a more accurate picture.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
