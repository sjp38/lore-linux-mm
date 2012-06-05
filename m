Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 2A6C86B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 10:37:02 -0400 (EDT)
Date: Tue, 5 Jun 2012 09:36:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/5] vmevent: Refresh vmstats before sampling
In-Reply-To: <1338553446-22292-3-git-send-email-anton.vorontsov@linaro.org>
Message-ID: <alpine.DEB.2.00.1206050934330.26918@router.home>
References: <20120601122118.GA6128@lizard> <1338553446-22292-3-git-send-email-anton.vorontsov@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, 1 Jun 2012, Anton Vorontsov wrote:

> On SMP, kernel updates vmstats only once per second, which makes vmevent
> unusable. Let's fix it by updating vmstats before sampling.

Well this may increase your accuracy but there is no guarantee that an
update to vm counters will not happen immediately after you have refreshed
the counters for one processor or the other.

Also please consider the impact that a IPI broadcast will have on latency
of other processors and to the function that is currently executing.

We just went through a round of getting rid of IPI broadcast because they
create OS noise on processors.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
