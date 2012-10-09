Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 2A3EB6B0072
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 01:03:38 -0400 (EDT)
Date: Tue, 9 Oct 2012 14:07:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: CMA and zone watermarks
Message-ID: <20121009050748.GH13817@bbox>
References: <CAH+eYFCJTtF+FeqKs_ho5yyX0tkUBoaa-yfsd1rVshcQ5Xxp=A@mail.gmail.com>
 <20121009031023.GF13817@bbox>
 <50739615.9080205@samsung.com>
 <20121009044317.GG13817@bbox>
 <5073ADC9.7030201@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5073ADC9.7030201@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Rabin Vincent <rabin@rab.in>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 09, 2012 at 06:53:29AM +0200, Marek Szyprowski wrote:
> Hello,
> 
> On 10/9/2012 6:43 AM, Minchan Kim wrote:
> >On Tue, Oct 09, 2012 at 05:12:21AM +0200, Marek Szyprowski wrote:
> >>On 10/9/2012 5:10 AM, Minchan Kim wrote:
> >>>On Mon, Oct 08, 2012 at 05:41:14PM +0200, Rabin Vincent wrote:
> 
> >>>Fortunately, recently, Bart sent a patch about that.
> >>>http://marc.info/?l=linux-mm&m=134763299016693&w=2
> >>>
> >>>Could you test above patches in your kernel?
> >>>You have to apply [2/4], [3/4], [4/4] and don't need [1/4].
> >>
> >>AFAIR without patch [1/4], free cma page counter will go below zero
> >>and weird thing will happen, so better apply the complete patchset.
> >
> >I can't understand your point. [1/4] is just fix for correcting trace
> >No?
> 
> I just remember we ran into such strange negative number of free cma
> pages issue without that patch, but maybe the final patchset will
> simply fail to apply without the first patch.

I have no objection to apply them all, of course.
But note that if you suffer from such strange bug without [1/4],
it should be dug in without buring into just "fixing of the trace"
comment. As I saw the code without [1/4], I can't find any fault.
Could you elaborat it more if you have any guessing in mind?

> 
> Best regards
> -- 
> Marek Szyprowski
> Samsung Poland R&D Center
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
