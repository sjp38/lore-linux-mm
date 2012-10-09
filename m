Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 669D16B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 06:16:24 -0400 (EDT)
Date: Tue, 9 Oct 2012 11:16:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] vmevent: Implement pressure attribute
Message-ID: <20121009101618.GR29125@suse.de>
References: <20121004110524.GA1821@lizard>
 <20121005092912.GA29125@suse.de>
 <20121007081414.GA18047@lizard>
 <20121008094646.GI29125@suse.de>
 <507380F8.4000401@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <507380F8.4000401@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Colin Cross <ccross@android.com>, Arve Hj?nnev?g <arve@android.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Oct 08, 2012 at 06:42:16PM -0700, John Stultz wrote:
> On 10/08/2012 02:46 AM, Mel Gorman wrote:
> >On Sun, Oct 07, 2012 at 01:14:17AM -0700, Anton Vorontsov wrote:
> >>And here we just try to let userland to assist, userland can tell "oh,
> >>don't bother with swapping or draining caches, I can just free some
> >>memory".
> >>
> >>Quite interesting, this also very much resembles volatile mmap ranges
> >>(i.e. the work that John Stultz is leading in parallel).
> >>
> >Agreed. I haven't been paying close attention to those patches but it
> >seems to me that one possiblity is that a listener for a vmevent would
> >set volatile ranges in response.
> 
> I don't have too much to comment on the rest of this mail, but just
> wanted to pipe in here, as the volatile ranges have caused some
> confusion.
> 
> While your suggestion would be possible, with volatile ranges, I've
> been promoting a more hands off-approach from the application
> perspective, where the application always would mark data that could
> be regenerated as volatile, unmarking it when accessing it.
> 
> This way the application doesn't need to be responsive to memory
> pressure, the kernel just takes what it needs from what the
> application made available.
> 
> Only when the application needs the data again, would it mark it
> non-volatile (or alternatively with the new SIGBUS semantics, access
> the purged volatile data and catch a SIGBUS), find the data was
> purged and regenerate it.
> 

Ok understood.

> That said, hybrid approaches like you suggested would be possible,
> but at a certain point, if we're waiting for a notification to take
> action, it might be better just to directly free that memory, rather
> then just setting it as volatile, and leaving it to the kernel then
> reclaim it for you.
> 

That's fine. I did not mean to suggest that volatile and vmevents on
memory pressure should be related or depending on each other in any way.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
