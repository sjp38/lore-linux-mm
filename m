Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 005E16B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:26:03 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1124125pad.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 02:26:03 -0700 (PDT)
Date: Thu, 25 Oct 2012 02:23:05 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v2 0/2] vmevent: A bit reworked pressure attribute + docs +
 man page
Message-ID: <20121025092305.GA32417@lizard>
References: <20121022111928.GA12396@lizard>
 <20121025064009.GA15767@bbox>
 <20121025090813.GA16078@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121025090813.GA16078@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Thu, Oct 25, 2012 at 02:08:14AM -0700, Anton Vorontsov wrote:
[...]
> Maybe it makes sense to implement something like PRESSURE_MILD with an
> additional nr_pages threshold, which basically hits the kernel about how
> many easily reclaimable pages userland has (that would be a part of our
> definition for the mild pressure level). So, essentially it will be
> 
> 	if (pressure_index >= oom_level)
> 		return PRESSURE_OOM;
> 	else if (pressure_index >= med_level)
> 		return PRESSURE_MEDIUM;
> 	else if (userland_reclaimable_pages >= nr_reclaimable_pages)
> 		return PRESSURE_MILD;

...or we can call it PRESSURE_BALANCE, just to be precise and clear.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
