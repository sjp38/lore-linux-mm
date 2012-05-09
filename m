Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C4C056B010D
	for <linux-mm@kvack.org>; Wed,  9 May 2012 11:28:10 -0400 (EDT)
Date: Wed, 9 May 2012 11:27:58 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v2 01/16] FS: Added demand paging markers to filesystem
Message-ID: <20120509152758.GB16341@redhat.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <1336054995-22988-2-git-send-email-svenkatr@ti.com>
 <20120506233117.GU5091@dastard>
 <CANfBPZ_2JeWUu7ti97CVc=ODeEi65ke9EKV6Uje0JHcCM8gYqQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANfBPZ_2JeWUu7ti97CVc=ODeEi65ke9EKV6Uje0JHcCM8gYqQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "S, Venkatraman" <svenkatr@ti.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Mon, May 07, 2012 at 10:16:30PM +0530, S, Venkatraman wrote:

[..]
> This feature doesn't fiddle with the I/O scheduler's ability to balance
> read vs write requests or handling requests from various process queues (CFQ).
> 

Does this feature work with CFQ? As CFQ does not submit sync IO (for
idling queues) while async IO is pending and vice a versa (cfq_may_dispatch()).

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
