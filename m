Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 202F16B006E
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:03:14 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so207960lag.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 02:03:12 -0700 (PDT)
Date: Wed, 24 Oct 2012 12:03:10 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [RFC 1/2] vmevent: Implement pressure attribute
In-Reply-To: <20121022112149.GA29325@lizard>
Message-ID: <alpine.LFD.2.02.1210241159590.13035@tux.localdomain>
References: <20121022111928.GA12396@lizard> <20121022112149.GA29325@lizard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

On Mon, 22 Oct 2012, Anton Vorontsov wrote:
> This patch introduces VMEVENT_ATTR_PRESSURE, the attribute reports Linux
> virtual memory management pressure. There are three discrete levels:
> 
> VMEVENT_PRESSURE_LOW: Notifies that the system is reclaiming memory for
> new allocations. Monitoring reclaiming activity might be useful for
> maintaining overall system's cache level.
> 
> VMEVENT_PRESSURE_MED: The system is experiencing medium memory pressure,
> there is some mild swapping activity. Upon this event applications may
> decide to free any resources that can be easily reconstructed or re-read
> from a disk.

Nit:

s/VMEVENT_PRESSURE_MED/VMEVENT_PRESSUDE_MEDIUM/

Other than that, I'm OK with this. Mel and others, what are your thoughts 
on this?

Anton, have you tested this with real world scenarios? How does it stack 
up against Android's low memory killer, for example?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
