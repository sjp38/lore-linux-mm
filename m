Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 2914D6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 10:04:35 -0500 (EST)
Date: Fri, 4 Jan 2013 17:05:40 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130104150540.GA14153@shutemov.name>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jan 04, 2013 at 12:29:11AM -0800, Anton Vorontsov wrote:
> This commit implements David Rientjes' idea of mempressure cgroup.
> 
> The main characteristics are the same to what I've tried to add to vmevent
> API; internally, it uses Mel Gorman's idea of scanned/reclaimed ratio for
> pressure index calculation. But we don't expose the index to the userland.
> Instead, there are three levels of the pressure:
> 
>  o low (just reclaiming, e.g. caches are draining);
>  o medium (allocation cost becomes high, e.g. swapping);
>  o oom (about to oom very soon).
> 
> The rationale behind exposing levels and not the raw pressure index
> described here: http://lkml.org/lkml/2012/11/16/675
> 
> For a task it is possible to be in both cpusets, memcg and mempressure
> cgroups, so by rearranging the tasks it is possible to watch a specific
> pressure (i.e. caused by cpuset and/or memcg).
> 
> Note that while this adds the cgroups support, the code is well separated
> and eventually we might add a lightweight, non-cgroups API, i.e. vmevent.
> But this is another story.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
