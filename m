Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 605D46B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 07:54:01 -0400 (EDT)
Received: by iyn15 with SMTP id 15so5988312iyn.34
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 04:53:59 -0700 (PDT)
Subject: Re: [PATCH] writeback: Per-block device
 bdi->dirty_writeback_interval and bdi->dirty_expire_interval.
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Fri, 19 Aug 2011 14:55:43 +0300
In-Reply-To: <20110818131343.GA17473@localhost>
References: 
	<CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
	 <20110818094824.GA25752@localhost> <1313669702.6607.24.camel@sauron>
	 <20110818131343.GA17473@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Message-ID: <1313754949.6607.52.camel@sauron>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Kautuk Consul <consul.kautuk@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

On Thu, 2011-08-18 at 21:13 +0800, Wu Fengguang wrote:
> Thinking twice about it, I find that the different requirements for
> interval flash/external microSD can also be solved by this scheme.
> 
> Introduce a per-bdi dirty_background_time (and optionally dirty_time)
> as the counterpart of (and works in parallel to) global dirty[_background]_ratio,
> however with unit "milliseconds worth of data".
> 
> The per-bdi dirty_background_time will be set low for external microSD
> and high for internal flash. Then you get timely writeouts for microSD
> and reasonably delayed writes for internal flash (controllable by the
> global dirty_expire_centisecs).
> 
> The dirty_background_time will actually work more reliable than
> dirty_expire_centisecs because it will checked immediately after the
> application dirties more pages. And the dirty_time could provide
> strong data integrity guarantee -- much stronger than
> dirty_expire_centisecs -- if used.
> 
> Does that sound reasonable?

Yes, this would probably work. But note, we do not have this problem
anymore, I was just talking about the past experience, so I cannot
validate any possible patch.

Thanks.

-- 
Best Regards,
Artem Bityutskiy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
