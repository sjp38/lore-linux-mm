Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id EB1396B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 06:20:00 -0500 (EST)
Date: Wed, 7 Nov 2012 13:21:36 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121107112136.GA31715@shutemov.name>
References: <20121107105348.GA25549@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121107105348.GA25549@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Wed, Nov 07, 2012 at 02:53:49AM -0800, Anton Vorontsov wrote:
> Hi all,
> 
> This is the third RFC. As suggested by Minchan Kim, the API is much
> simplified now (comparing to vmevent_fd):
> 
> - As well as Minchan, KOSAKI Motohiro didn't like the timers, so the
>   timers are gone now;
> - Pekka Enberg didn't like the complex attributes matching code, and so it
>   is no longer there;
> - Nobody liked the raw vmstat attributes, and so they were eliminated too.
> 
> But, conceptually, it is the exactly the same approach as in v2: three
> discrete levels of the pressure -- low, medium and oom. The levels are
> based on the reclaimer inefficiency index as proposed by Mel Gorman, but
> userland does not see the raw index values. The description why I moved
> away from reporting the raw 'reclaimer inefficiency index' can be found in
> v2: http://lkml.org/lkml/2012/10/22/177
> 
> While the new API is very simple, it is still extensible (i.e. versioned).

Sorry, I didn't follow previous discussion on this, but could you
explain what's wrong with memory notifications from memcg?
As I can see you can get pretty similar functionality using memory
thresholds on the root cgroup. What's the point?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
