Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id DD1736B0044
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 03:34:40 -0400 (EDT)
Date: Thu, 20 Sep 2012 16:37:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3] memory-hotplug: fix zone stat mismatch
Message-ID: <20120920073719.GH13234@bbox>
References: <1348123405-30641-1-git-send-email-minchan@kernel.org>
 <505AC3E9.4030009@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <505AC3E9.4030009@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Yasuaki,

On Thu, Sep 20, 2012 at 04:21:13PM +0900, Yasuaki Ishimatsu wrote:
> Hi Minchan,
> 
> Sorry for late reply.
> 
> 2012/09/20 15:43, Minchan Kim wrote:
> > During memory-hotplug, I found NR_ISOLATED_[ANON|FILE]
> > are increasing so that kernel are hang out.
> 
> Why does your system hang out by increasing NR_ISOLATED_[ANON|FILE]?
> I cannot understand what has happened by your system.

If system doesn't have enough free page, it goes reclaim path and never
reclaim any pages by too_many_isolated and loop forever.

--
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
